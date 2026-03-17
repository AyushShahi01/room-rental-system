"""
Serializers for the accounts app.

Handles validation, data transformation, and business logic
for all authentication-related API endpoints.
"""
from django.contrib.auth import authenticate
from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers
from rest_framework_simplejwt.tokens import RefreshToken

from .models import User, Profile


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  User / Profile Serializers (Read-only)                                     ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

class ProfileSerializer(serializers.ModelSerializer):
    """Read-only serializer for user profile data."""

    class Meta:
        model = Profile
        fields = [
            'profile_picture', 'address', 'occupation',
            'date_of_birth', 'created_at', 'updated_at',
        ]
        read_only_fields = fields


class UserSerializer(serializers.ModelSerializer):
    """
    Serializer for the authenticated user's data.
    Used by the /me endpoint.
    """
    profile = ProfileSerializer(read_only=True)

    class Meta:
        model = User
        fields = [
            'id', 'email', 'full_name', 'phone', 'role',
            'is_active', 'is_verified', 'created_at', 'profile',
        ]
        read_only_fields = fields


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Register Serializer                                                        ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

class RegisterSerializer(serializers.ModelSerializer):
    """
    Handles user registration.

    Validates:
    - Email uniqueness
    - Password strength (Django validators)
    - Password confirmation match
    - Role is valid
    """
    password = serializers.CharField(
        write_only=True,
        min_length=8,
        style={'input_type': 'password'},
    )
    password_confirm = serializers.CharField(
        write_only=True,
        style={'input_type': 'password'},
    )

    class Meta:
        model = User
        fields = [
            'email', 'full_name', 'phone', 'role',
            'password', 'password_confirm',
        ]

    def validate_email(self, value):
        """Ensure the email is not already registered (case-insensitive)."""
        if User.all_objects.filter(email__iexact=value).exists():
            raise serializers.ValidationError(
                'A user with this email already exists.'
            )
        return value.lower()

    def validate_password(self, value):
        """Run Django's built-in password validators."""
        validate_password(value)
        return value

    def validate(self, attrs):
        """Ensure password and password_confirm match."""
        if attrs['password'] != attrs.pop('password_confirm'):
            raise serializers.ValidationError({
                'password_confirm': 'Passwords do not match.',
            })
        return attrs

    def create(self, validated_data):
        """Create user with hashed password and auto-create profile."""
        user = User.objects.create_user(
            email=validated_data['email'],
            password=validated_data['password'],
            full_name=validated_data.get('full_name', ''),
            phone=validated_data.get('phone'),
            role=validated_data.get('role', User.Role.TENANT),
        )
        # Auto-create a profile for the new user
        Profile.objects.create(user=user)
        return user


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Login Serializer                                                           ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

class LoginSerializer(serializers.Serializer):
    """
    Handles user login.

    Validates credentials and returns JWT tokens.
    """
    email = serializers.EmailField()
    password = serializers.CharField(
        write_only=True,
        style={'input_type': 'password'},
    )

    def validate(self, attrs):
        email = attrs.get('email', '').lower()
        password = attrs.get('password')

        if not email or not password:
            raise serializers.ValidationError(
                'Both email and password are required.'
            )

        # Authenticate using Django's auth backend
        user = authenticate(
            request=self.context.get('request'),
            email=email,
            password=password,
        )

        if not user:
            raise serializers.ValidationError(
                'Invalid email or password.'
            )

        if not user.is_active:
            raise serializers.ValidationError(
                'This account has been deactivated.'
            )

        attrs['user'] = user
        return attrs

    def get_tokens(self, user):
        """Generate JWT token pair for the user."""
        refresh = RefreshToken.for_user(user)
        return {
            'refresh': str(refresh),
            'access': str(refresh.access_token),
        }


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Logout Serializer                                                          ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

class LogoutSerializer(serializers.Serializer):
    """
    Handles user logout by blacklisting the refresh token.
    """
    refresh = serializers.CharField(
        help_text='The refresh token to blacklist.',
    )

    def validate_refresh(self, value):
        """Validate that the refresh token is not empty."""
        if not value:
            raise serializers.ValidationError(
                'Refresh token is required.'
            )
        return value

    def save(self):
        """Blacklist the refresh token."""
        try:
            token = RefreshToken(self.validated_data['refresh'])
            token.blacklist()
        except Exception:
            raise serializers.ValidationError(
                'Invalid or expired refresh token.'
            )


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Password Serializers                                                       ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

class ChangePasswordSerializer(serializers.Serializer):
    """
    Handles password change for authenticated users.
    Requires the current password for security.
    """
    old_password = serializers.CharField(
        write_only=True,
        style={'input_type': 'password'},
    )
    new_password = serializers.CharField(
        write_only=True,
        min_length=8,
        style={'input_type': 'password'},
    )
    new_password_confirm = serializers.CharField(
        write_only=True,
        style={'input_type': 'password'},
    )

    def validate_old_password(self, value):
        """Verify the current password is correct."""
        user = self.context['request'].user
        if not user.check_password(value):
            raise serializers.ValidationError(
                'Current password is incorrect.'
            )
        return value

    def validate_new_password(self, value):
        """Run Django's built-in password validators."""
        validate_password(value, self.context['request'].user)
        return value

    def validate(self, attrs):
        if attrs['new_password'] != attrs['new_password_confirm']:
            raise serializers.ValidationError({
                'new_password_confirm': 'New passwords do not match.',
            })
        return attrs

    def save(self):
        user = self.context['request'].user
        user.set_password(self.validated_data['new_password'])
        user.save(update_fields=['password'])
        return user


class ForgotPasswordSerializer(serializers.Serializer):
    """
    Initiates the forgot password flow.
    Sends an OTP to the user's email.
    """
    email = serializers.EmailField()

    def validate_email(self, value):
        """Normalize and check if email exists."""
        value = value.lower()
        # We deliberately don't reveal whether the email exists
        # to prevent email enumeration attacks.
        return value


class ResetPasswordSerializer(serializers.Serializer):
    """
    Handles password reset using an OTP.
    """
    email = serializers.EmailField()
    otp_code = serializers.CharField(max_length=6, min_length=6)
    new_password = serializers.CharField(
        write_only=True,
        min_length=8,
        style={'input_type': 'password'},
    )

    def validate_new_password(self, value):
        validate_password(value)
        return value


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Email Verification Serializers                                             ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

class VerifyEmailSerializer(serializers.Serializer):
    """Verifies email address using OTP."""
    email = serializers.EmailField()
    otp_code = serializers.CharField(max_length=6, min_length=6)


class ResendVerificationSerializer(serializers.Serializer):
    """Resends email verification OTP."""
    email = serializers.EmailField()