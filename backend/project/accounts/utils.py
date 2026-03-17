"""
Utility functions for the accounts app.
"""
import random
import string
from datetime import timedelta

from django.conf import settings
from django.core.mail import send_mail
from django.utils import timezone

from .models import OtpVerification


def generate_otp(length=6):
    """Generate a random numeric OTP of the specified length."""
    return ''.join(random.choices(string.digits, k=length))


def create_and_send_otp(user, otp_type):
    """
    Generate an OTP, save it to the database, and send via email.

    Args:
        user: The User instance to send the OTP to.
        otp_type: One of OtpVerification.OtpType choices
                  ('email_verify' or 'password_reset').

    Returns:
        The created OtpVerification instance.
    """
    # Invalidate any existing unused OTPs of the same type for this user
    OtpVerification.objects.filter(
        user=user,
        otp_type=otp_type,
        is_used=False,
    ).update(is_used=True)

    # Generate new OTP
    otp_code = generate_otp()
    expiry_minutes = getattr(settings, 'OTP_EXPIRY_MINUTES', 10)

    otp = OtpVerification.objects.create(
        user=user,
        otp_code=otp_code,
        otp_type=otp_type,
        expires_at=timezone.now() + timedelta(minutes=expiry_minutes),
    )

    # Determine email subject and body based on OTP type
    if otp_type == OtpVerification.OtpType.EMAIL_VERIFY:
        subject = 'Verify Your Email Address'
        message = (
            f'Hello {user.full_name or user.email},\n\n'
            f'Your email verification code is: {otp_code}\n\n'
            f'This code will expire in {expiry_minutes} minutes.\n\n'
            f'If you did not request this, please ignore this email.'
        )
    else:  # PASSWORD_RESET
        subject = 'Password Reset Request'
        message = (
            f'Hello {user.full_name or user.email},\n\n'
            f'Your password reset code is: {otp_code}\n\n'
            f'This code will expire in {expiry_minutes} minutes.\n\n'
            f'If you did not request this, please ignore this email.\n'
            f'Your password will remain unchanged.'
        )

    # Send the email
    send_mail(
        subject=subject,
        message=message,
        from_email=settings.DEFAULT_FROM_EMAIL,
        recipient_list=[user.email],
        fail_silently=False,
    )

    return otp


def get_client_ip(request):
    """Extract the client IP address from the request."""
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        return x_forwarded_for.split(',')[0].strip()
    return request.META.get('REMOTE_ADDR')


def get_user_agent(request):
    """Extract the User-Agent string from the request."""
    return request.META.get('HTTP_USER_AGENT', '')
