"""
Admin configuration for accounts app models.

Provides a rich admin interface for managing users, profiles,
OTP verifications, device tracking, and login history.
"""
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin

from .models import (
    DeviceTracking,
    LoginHistory,
    OtpVerification,
    Profile,
    User,
)


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Profile Inline (shown inside User admin)                                   ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

class ProfileInline(admin.StackedInline):
    model = Profile
    can_delete = False
    verbose_name_plural = 'Profile'
    fk_name = 'user'


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  User Admin                                                                 ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

@admin.register(User)
class UserAdmin(BaseUserAdmin):
    """Custom admin for the User model with email-based auth."""

    inlines = [ProfileInline]

    list_display = (
        'email', 'full_name', 'role', 'is_active',
        'is_verified', 'is_staff', 'created_at',
    )
    list_filter = ('role', 'is_active', 'is_verified', 'is_staff', 'is_deleted')
    search_fields = ('email', 'full_name', 'phone')
    ordering = ('-created_at',)

    # Fieldsets for the edit page
    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        ('Personal Info', {'fields': ('full_name', 'phone')}),
        ('Permissions', {
            'fields': ('role', 'is_active', 'is_verified', 'is_staff', 'is_superuser'),
        }),
        ('Soft Delete', {
            'fields': ('is_deleted', 'deleted_at'),
            'classes': ('collapse',),
        }),
        ('Important Dates', {
            'fields': ('last_login', 'created_at'),
        }),
    )
    readonly_fields = ('created_at', 'last_login')

    # Fieldsets for the add user page
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': (
                'email', 'full_name', 'phone', 'role',
                'password1', 'password2',
                'is_active', 'is_staff', 'is_verified',
            ),
        }),
    )


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Other Model Admins                                                        ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'occupation', 'created_at')
    search_fields = ('user__email', 'occupation')


@admin.register(OtpVerification)
class OtpVerificationAdmin(admin.ModelAdmin):
    list_display = ('user', 'otp_type', 'otp_code', 'is_used', 'created_at', 'expires_at')
    list_filter = ('otp_type', 'is_used')
    search_fields = ('user__email',)
    readonly_fields = ('created_at',)


@admin.register(DeviceTracking)
class DeviceTrackingAdmin(admin.ModelAdmin):
    list_display = ('user', 'device_name', 'ip_address', 'is_trusted', 'last_used_at')
    list_filter = ('is_trusted',)
    search_fields = ('user__email', 'device_name', 'ip_address')


@admin.register(LoginHistory)
class LoginHistoryAdmin(admin.ModelAdmin):
    list_display = ('user', 'status', 'ip_address', 'timestamp')
    list_filter = ('status',)
    search_fields = ('user__email', 'ip_address')
    readonly_fields = ('timestamp',)
