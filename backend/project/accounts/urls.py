"""
URL configuration for the accounts app.

All endpoints are prefixed with /api/v1/auth/ (configured in project/urls.py).
"""
from django.urls import path

from . import views

app_name = 'accounts'

urlpatterns = [
    # ─── Authentication ─────────────────────────────────────────────────────
    path('register/',   views.RegisterView.as_view(),             name='register'),
    path('login/',      views.LoginView.as_view(),                name='login'),
    path('logout/',     views.LogoutView.as_view(),               name='logout'),
    path('refresh/',    views.CustomTokenRefreshView.as_view(),   name='token-refresh'),
    path('me/',         views.MeView.as_view(),                   name='me'),

    # ─── Email Verification ─────────────────────────────────────────────────
    path('verify-email/',         views.VerifyEmailView.as_view(),         name='verify-email'),
    path('resend-verification/',  views.ResendVerificationView.as_view(),  name='resend-verification'),

    # ─── Password Management ────────────────────────────────────────────────
    path('forgot-password/',  views.ForgotPasswordView.as_view(),   name='forgot-password'),
    path('reset-password/',   views.ResetPasswordView.as_view(),    name='reset-password'),
    path('change-password/',  views.ChangePasswordView.as_view(),   name='change-password'),
]
