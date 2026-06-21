from rest_framework import permissions

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
