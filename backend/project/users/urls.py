from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from . import views

urlpatterns = [
    path('register/', views.RegisterView.as_view(), name='register'),
    path('login/', views.LoginView.as_view(), name='login'),
    path('logout/', views.LogoutView.as_view(), name='logout'),
    path('refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('me/', views.UserProfileView.as_view(), name='me'),
    path('me/update/', views.UserProfileView.as_view(), name='me-update'),
    path('me/profile-picture/', views.UserProfilePictureUploadView.as_view(), name='me-profile-picture'),
    path('change-password/', views.ChangePasswordView.as_view(), name='change-password'),
    path('device-token/', views.DeviceTokenView.as_view(), name='device-token'),
    path('otp/send/', views.OTPSendView.as_view(), name='otp-send'),
    path('otp/verify/', views.OTPVerifyView.as_view(), name='otp-verify'),
    path('admin/users/', views.AdminUserListView.as_view(), name='admin-users'),
    path('admin/users/<uuid:pk>/ban/', views.BanUserView.as_view(), name='ban-user'),
    path('admin/dashboard/', views.AdminDashboardView.as_view(), name='admin-dashboard'),
]
