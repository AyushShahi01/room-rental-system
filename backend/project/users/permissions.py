from rest_framework import permissions
from rest_framework.permissions import BasePermission

class IsTenant(permissions.BasePermission):
    """
    Allows access only to tenant users.
    """
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and getattr(request.user, 'role', None) == 'tenant')

class IsLandlord(permissions.BasePermission):
    """
    Allows access only to landlord users.
    """
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and getattr(request.user, 'role', None) == 'landlord')

class IsAdmin(permissions.BasePermission):
    """
    Allows access only to admin users.
    """
    def has_permission(self, request, view):
        return bool(
            request.user and 
            request.user.is_authenticated and 
            (getattr(request.user, 'role', None) == 'admin' or request.user.is_staff)
        )

class IsEmailVerified(BasePermission):
    """
    Allows access only to users who have verified their email address.
    """
    message = "Email verification is required to access this resource."

    def has_permission(self, request, view):
        return bool(
            request.user and
            request.user.is_authenticated and
            getattr(request.user, 'is_email_verified', False)
        )
