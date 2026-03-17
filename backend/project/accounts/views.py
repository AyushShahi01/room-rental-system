"""
API views for user authentication and account management.

All endpoints follow RESTful conventions with proper error handling
and consistent response format.
"""
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenRefreshView

from .models import (
    DeviceTracking,
    LoginHistory,
    OtpVerification,
    User,
)
from .serializers import (
    ChangePasswordSerializer,
    ForgotPasswordSerializer,
    LoginSerializer,
    LogoutSerializer,
    RegisterSerializer,
    ResendVerificationSerializer,
    ResetPasswordSerializer,
    UserSerializer,
    VerifyEmailSerializer,
)
from .utils import create_and_send_otp, get_client_ip, get_user_agent


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Register                                                                   ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

class RegisterView(APIView):
    """
    POST /api/v1/auth/register

    Register a new user account.
    Sends an email verification OTP upon successful registration.
    """
    permission_classes = [AllowAny]
    throttle_scope = 'register'

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        # Send email verification OTP
        try:
            create_and_send_otp(user, OtpVerification.OtpType.EMAIL_VERIFY)
        except Exception:
            # Don't fail registration if email sending fails
            pass

        return Response(
            {
                'message': 'Registration successful. Please check your email for verification.',
                'user': UserSerializer(user).data,
            },
            status=status.HTTP_201_CREATED,
        )


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Login                                                                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

class LoginView(APIView):
    """
    POST /api/v1/auth/login

    Authenticate a user and return JWT tokens.
    Records device info and login history.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(
            data=request.data,
            context={'request': request},
        )

        # Extract request metadata for logging
        ip_address = get_client_ip(request)
        user_agent = get_user_agent(request)

        if not serializer.is_valid():
            # Log failed login attempt if we can identify the user
            email = request.data.get('email', '').lower()
            try:
                user = User.objects.get(email=email)
                LoginHistory.objects.create(
                    user=user,
                    ip_address=ip_address,
                    user_agent=user_agent,
                    status=LoginHistory.Status.FAILED,
                    failure_reason='Invalid credentials',
                )
            except User.DoesNotExist:
                pass

            return Response(
                {'errors': serializer.errors},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        user = serializer.validated_data['user']
        tokens = serializer.get_tokens(user)

        # Record successful login
        LoginHistory.objects.create(
            user=user,
            ip_address=ip_address,
            user_agent=user_agent,
            status=LoginHistory.Status.SUCCESS,
        )

        # Track device (update existing or create new)
        DeviceTracking.objects.update_or_create(
            user=user,
            user_agent=user_agent,
            defaults={
                'ip_address': ip_address,
                'device_name': user_agent[:255] if user_agent else '',
            },
        )

        return Response(
            {
                'message': 'Login successful.',
                'tokens': tokens,
                'user': UserSerializer(user).data,
            },
            status=status.HTTP_200_OK,
        )


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Logout                                                                     ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

class LogoutView(APIView):
    """
    POST /api/v1/auth/logout

    Blacklist the provided refresh token to log the user out.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = LogoutSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response(
            {'message': 'Logged out successfully.'},
            status=status.HTTP_200_OK,
        )


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Me (Authenticated User Profile)                                            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

class MeView(APIView):
    """
    GET /api/v1/auth/me

    Return the authenticated user's profile data.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data, status=status.HTTP_200_OK)


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Refresh Token                                                              ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

class CustomTokenRefreshView(TokenRefreshView):
    """
    POST /api/v1/auth/refresh

    Use Simple JWT's built-in token refresh with rotation + blacklist.
    We subclass to allow unauthenticated access (you send just the refresh token).
    """
    permission_classes = [AllowAny]


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Email Verification                                                         ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

class VerifyEmailView(APIView):
    """
    POST /api/v1/auth/verify-email

    Verify the user's email using an OTP code.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = VerifyEmailSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        email = serializer.validated_data['email'].lower()
        otp_code = serializer.validated_data['otp_code']

        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response(
                {'error': 'No account found with this email.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        if user.is_verified:
            return Response(
                {'message': 'Email is already verified.'},
                status=status.HTTP_200_OK,
            )

        # Find a valid OTP
        otp = OtpVerification.objects.filter(
            user=user,
            otp_type=OtpVerification.OtpType.EMAIL_VERIFY,
            is_used=False,
        ).order_by('-created_at').first()

        if not otp or not otp.is_valid:
            return Response(
                {'error': 'OTP has expired or is invalid. Please request a new one.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if otp.otp_code != otp_code:
            otp.attempt_count += 1
            otp.save(update_fields=['attempt_count'])
            return Response(
                {'error': 'Invalid OTP code.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Mark OTP as used and verify user
        otp.is_used = True
        otp.save(update_fields=['is_used'])
        user.is_verified = True
        user.save(update_fields=['is_verified'])

        return Response(
            {'message': 'Email verified successfully.'},
            status=status.HTTP_200_OK,
        )


class ResendVerificationView(APIView):
    """
    POST /api/v1/auth/resend-verification

    Resend the email verification OTP.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = ResendVerificationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        email = serializer.validated_data['email'].lower()

        # Always return success to prevent email enumeration
        try:
            user = User.objects.get(email=email)
            if not user.is_verified:
                create_and_send_otp(user, OtpVerification.OtpType.EMAIL_VERIFY)
        except User.DoesNotExist:
            pass

        return Response(
            {'message': 'If an unverified account exists with this email, a verification code has been sent.'},
            status=status.HTTP_200_OK,
        )


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Forgot / Reset Password                                                    ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

class ForgotPasswordView(APIView):
    """
    POST /api/v1/auth/forgot-password

    Initiate password reset by sending an OTP to the user's email.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = ForgotPasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        email = serializer.validated_data['email'].lower()

        # Always return success to prevent email enumeration
        try:
            user = User.objects.get(email=email)
            create_and_send_otp(user, OtpVerification.OtpType.PASSWORD_RESET)
        except User.DoesNotExist:
            pass

        return Response(
            {'message': 'If an account exists with this email, a password reset code has been sent.'},
            status=status.HTTP_200_OK,
        )


class ResetPasswordView(APIView):
    """
    POST /api/v1/auth/reset-password

    Reset the user's password using an OTP code.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = ResetPasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        email = serializer.validated_data['email'].lower()
        otp_code = serializer.validated_data['otp_code']
        new_password = serializer.validated_data['new_password']

        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response(
                {'error': 'No account found with this email.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Find a valid password reset OTP
        otp = OtpVerification.objects.filter(
            user=user,
            otp_type=OtpVerification.OtpType.PASSWORD_RESET,
            is_used=False,
        ).order_by('-created_at').first()

        if not otp or not otp.is_valid:
            return Response(
                {'error': 'OTP has expired or is invalid. Please request a new one.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if otp.otp_code != otp_code:
            otp.attempt_count += 1
            otp.save(update_fields=['attempt_count'])
            return Response(
                {'error': 'Invalid OTP code.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Reset password and mark OTP as used
        otp.is_used = True
        otp.save(update_fields=['is_used'])
        user.set_password(new_password)
        user.save(update_fields=['password'])

        return Response(
            {'message': 'Password reset successfully. You can now log in with your new password.'},
            status=status.HTTP_200_OK,
        )


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Change Password (Authenticated)                                            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

class ChangePasswordView(APIView):
    """
    POST /api/v1/auth/change-password

    Change password for an authenticated user.
    Requires the current password for verification.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = ChangePasswordSerializer(
            data=request.data,
            context={'request': request},
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response(
            {'message': 'Password changed successfully.'},
            status=status.HTTP_200_OK,
        )
