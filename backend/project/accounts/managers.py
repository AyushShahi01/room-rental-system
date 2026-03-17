"""
Custom UserManager for email-based authentication.

Handles user creation with proper validation, normalization,
and password hashing.
"""
from django.contrib.auth.models import BaseUserManager
from django.core.exceptions import ValidationError
from django.core.validators import validate_email


class UserManager(BaseUserManager):
    """
    Custom manager for User model where email is the unique identifier
    for authentication instead of username.
    """

    def _validate_email(self, email):
        """Validate and normalize the email address."""
        if not email:
            raise ValueError('Users must have an email address.')
        try:
            validate_email(email)
        except ValidationError:
            raise ValueError('Please provide a valid email address.')
        return self.normalize_email(email)

    def create_user(self, email, password=None, **extra_fields):
        """
        Create and return a regular user with an email and password.

        - Validates and normalizes the email address
        - Hashes the password using set_password()
        - Sets sensible defaults for is_staff and is_superuser
        """
        email = self._validate_email(email)

        # Ensure regular users don't accidentally get elevated permissions
        extra_fields.setdefault('is_staff', False)
        extra_fields.setdefault('is_superuser', False)
        extra_fields.setdefault('is_active', True)

        user = self.model(email=email, **extra_fields)
        user.set_password(password)  # Hash the password — never store plain text
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        """
        Create and return a superuser with email and password.

        Enforces that superusers MUST have is_staff=True and is_superuser=True.
        """
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)
        extra_fields.setdefault('is_verified', True)
        extra_fields.setdefault('role', 'admin')

        # Safety check — superuser MUST have these flags
        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')

        return self.create_user(email, password, **extra_fields)
