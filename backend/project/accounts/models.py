"""
Accounts models — Custom User, Profile, OTP, Device Tracking, Login History.

All models use UUID primary keys and support soft deletion where appropriate.
"""
import uuid
from django.conf import settings
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin
from django.db import models
from django.utils import timezone

from .managers import UserManager


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Soft Delete Mixin                                                          ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

class SoftDeleteManager(models.Manager):
    """Default manager that automatically excludes soft-deleted records."""

    def get_queryset(self):
        return super().get_queryset().filter(is_deleted=False)


class AllObjectsManager(models.Manager):
    """Manager that includes soft-deleted records (for admin use)."""
    pass


class SoftDeleteModel(models.Model):
    """
    Abstract mixin that adds soft delete capability.

    Instead of permanently deleting records, sets is_deleted=True
    and records the deletion timestamp. Use `all_objects` manager
    to query deleted records.
    """
    is_deleted = models.BooleanField(default=False, db_index=True)
    deleted_at = models.DateTimeField(null=True, blank=True)

    objects = SoftDeleteManager()
    all_objects = AllObjectsManager()

    class Meta:
        abstract = True

    def soft_delete(self):
        """Mark the record as deleted instead of removing from DB."""
        self.is_deleted = True
        self.deleted_at = timezone.now()
        self.save(update_fields=['is_deleted', 'deleted_at'])

    def restore(self):
        """Restore a soft-deleted record."""
        self.is_deleted = False
        self.deleted_at = None
        self.save(update_fields=['is_deleted', 'deleted_at'])

    def hard_delete(self):
        """Permanently delete the record from the database."""
        super().delete()

    def delete(self, using=None, keep_parents=False):
        """Override default delete to perform soft delete."""
        self.soft_delete()


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  User Model                                                                 ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

class User(AbstractBaseUser, PermissionsMixin, SoftDeleteModel):
    """
    Custom User model using email as the unique identifier.

    - UUID primary key (no sequential integer IDs exposed)
    - Email-based authentication (no username)
    - Role-based access control (tenant, landlord, admin)
    - Soft delete support
    """

    class Role(models.TextChoices):
        TENANT = 'tenant', 'Tenant'
        LANDLORD = 'landlord', 'Landlord'
        ADMIN = 'admin', 'Admin'

    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False,
        help_text='Unique identifier for the user (UUID v4)',
    )
    email = models.EmailField(
        unique=True,
        db_index=True,
        help_text='Email address — used as the login identifier',
    )
    full_name = models.CharField(
        max_length=255,
        blank=True,
        help_text='Full name of the user',
    )
    phone = models.CharField(
        max_length=20,
        blank=True,
        null=True,
        help_text='Phone number (with country code)',
    )
    role = models.CharField(
        max_length=20,
        choices=Role.choices,
        default=Role.TENANT,
        db_index=True,
        help_text='User role for access control',
    )

    # Status fields
    is_active = models.BooleanField(
        default=True,
        help_text='Whether the user account is active',
    )
    is_staff = models.BooleanField(
        default=False,
        help_text='Whether the user can access the admin site',
    )
    is_verified = models.BooleanField(
        default=False,
        help_text='Whether the user has verified their email address',
    )

    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    # Auth configuration
    USERNAME_FIELD = 'email'    # Login with email instead of username
    REQUIRED_FIELDS = []        # Email & password are required by default

    # Custom manager
    objects = UserManager()
    all_objects = AllObjectsManager()

    class Meta:
        db_table = 'users'
        verbose_name = 'User'
        verbose_name_plural = 'Users'
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.email} ({self.role})'

    @property
    def short_name(self):
        """Return the first word of full_name, or email prefix."""
        if self.full_name:
            return self.full_name.split()[0]
        return self.email.split('@')[0]


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Profile Model                                                              ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

class Profile(models.Model):
    """
    Extended user profile — stores non-auth data.
    Auto-created when a user registers.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='profile',
    )
    profile_picture = models.ImageField(
        upload_to='profiles/%Y/%m/',
        blank=True,
        null=True,
    )
    address = models.CharField(max_length=500, blank=True, null=True)
    occupation = models.CharField(max_length=255, blank=True, null=True)
    date_of_birth = models.DateField(blank=True, null=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'profiles'

    def __str__(self):
        return f'Profile of {self.user.email}'


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  OTP Verification Model                                                     ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

class OtpVerification(models.Model):
    """
    Stores OTP codes for email verification and password reset.

    OTPs are single-use and expire after a configurable duration.
    """

    class OtpType(models.TextChoices):
        EMAIL_VERIFY = 'email_verify', 'Email Verification'
        PASSWORD_RESET = 'password_reset', 'Password Reset'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='otp_verifications',
    )
    otp_code = models.CharField(max_length=6)
    otp_type = models.CharField(
        max_length=20,
        choices=OtpType.choices,
        help_text='Purpose of the OTP',
    )
    attempt_count = models.IntegerField(
        default=0,
        help_text='Number of failed verification attempts',
    )
    is_used = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()

    class Meta:
        db_table = 'otp_verifications'
        ordering = ['-created_at']

    def __str__(self):
        return f'OTP ({self.otp_type}) for {self.user.email}'

    @property
    def is_expired(self):
        """Check if the OTP has passed its expiry time."""
        return timezone.now() > self.expires_at

    @property
    def is_valid(self):
        """Check if the OTP can still be used."""
        return not self.is_used and not self.is_expired and self.attempt_count < 5


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Device Tracking Model                                                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

class DeviceTracking(models.Model):
    """
    Tracks devices used to log into the platform.

    Helps with:
    - Security auditing
    - Detecting suspicious login activity
    - Device trust management
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='devices',
    )
    device_type = models.CharField(
        max_length=50,
        blank=True,
        help_text='e.g. Mobile, Desktop, Tablet',
    )
    device_name = models.CharField(
        max_length=255,
        blank=True,
        help_text='e.g. Chrome on Windows, Safari on iPhone',
    )
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(blank=True)
    last_used_at = models.DateTimeField(auto_now=True)
    is_trusted = models.BooleanField(
        default=False,
        help_text='Whether the user has marked this device as trusted',
    )

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'device_tracking'
        ordering = ['-last_used_at']
        verbose_name_plural = 'Device Tracking'

    def __str__(self):
        return f'{self.device_name} — {self.user.email}'


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Login History Model                                                        ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

class LoginHistory(models.Model):
    """
    Records every login attempt (success or failure).

    Useful for:
    - Security monitoring and alerting
    - Audit trails
    - Detecting brute-force attacks
    """

    class Status(models.TextChoices):
        SUCCESS = 'success', 'Success'
        FAILED = 'failed', 'Failed'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='login_history',
    )
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(blank=True)
    status = models.CharField(
        max_length=10,
        choices=Status.choices,
        db_index=True,
    )
    failure_reason = models.CharField(
        max_length=255,
        blank=True,
        help_text='Reason for login failure (if applicable)',
    )
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'login_history'
        ordering = ['-timestamp']
        verbose_name_plural = 'Login History'

    def __str__(self):
        return f'{self.user.email} — {self.status} at {self.timestamp}'