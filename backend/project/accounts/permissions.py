"""
Role-based permissions for the accounts app.

Usage in views:
    permission_classes = [IsAuthenticated, IsAdmin]
    permission_classes = [IsAuthenticated, IsVerified, IsLandlord]
"""
from rest_framework.permissions import BasePermission


class IsAdmin(BasePermission):
    """Allow access only to users with the 'admin' role."""

    def has_permission(self, request, view):
        return (
            request.user
            and request.user.is_authenticated
            and request.user.role == 'admin'
        )


class IsLandlord(BasePermission):
    """Allow access only to users with the 'landlord' role."""

    def has_permission(self, request, view):
        return (
            request.user
            and request.user.is_authenticated
            and request.user.role == 'landlord'
        )


class IsTenant(BasePermission):
    """Allow access only to users with the 'tenant' role."""

    def has_permission(self, request, view):
        return (
            request.user
            and request.user.is_authenticated
            and request.user.role == 'tenant'
        )


class IsVerified(BasePermission):
    """Allow access only to users who have verified their email."""

    message = 'Your email address is not verified. Please verify your email to continue.'

    def has_permission(self, request, view):
        return (
            request.user
            and request.user.is_authenticated
            and request.user.is_verified
        )


class IsLandlordOrAdmin(BasePermission):
    """Allow access to users with 'landlord' or 'admin' role."""

    def has_permission(self, request, view):
        return (
            request.user
            and request.user.is_authenticated
            and request.user.role in ('landlord', 'admin')
        )
