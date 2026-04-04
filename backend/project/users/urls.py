from django.urls import path
from .views import RegisterView, LoginView, LogoutView, UserProfileView, ChangePasswordView, AdminUserListView, AdminDashboardView, BanUserView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('logout/', LogoutView.as_view(), name='logout'),
    path('me/', UserProfileView.as_view(), name='me'),
    path('me/update/', UserProfileView.as_view(), name='me-update'),
    path('change-password/', ChangePasswordView.as_view(), name='change-password'),
    path('admin/users/', AdminUserListView.as_view(), name='admin-users'),
    path('admin/users/<int:pk>/ban/', BanUserView.as_view(), name='ban-user'),
    path('admin/dashboard/', AdminDashboardView.as_view(), name='admin-dashboard'),
]
