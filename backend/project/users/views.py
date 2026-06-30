from drf_spectacular.utils import extend_schema
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.exceptions import PermissionDenied
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
from django.conf import settings
from django.contrib.auth import get_user_model
from django.core.mail import send_mail
from django.utils import timezone
from datetime import timedelta
import random

from .serializers import (
    AuthResponseSerializer,
    ChangePasswordSerializer,
    DeviceTokenSerializer,
    ErrorResponseSerializer,
    LoginSerializer,
    LogoutSerializer,
    MessageResponseSerializer,
    OTPSendSerializer,
    OTPVerifySerializer,
    RegisterSerializer,
    UserSerializer,
)
from .models import OTP


class RegisterView(APIView):
    permission_classes = [AllowAny]

    @extend_schema(
        request=RegisterSerializer,
        responses={
            201: AuthResponseSerializer,
            400: ErrorResponseSerializer,
        },
    )
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        refresh = RefreshToken.for_user(user)

        response_data = {
            'message': 'Registration successful.',
            'tokens': {
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            },
            'user': UserSerializer(user).data,
        }
        return Response(response_data, status=status.HTTP_201_CREATED)

class LoginView(APIView):
    permission_classes = [AllowAny]

    @extend_schema(
        request=LoginSerializer,
        responses={
            200: AuthResponseSerializer,
            401: ErrorResponseSerializer,
        },
    )
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({'errors': serializer.errors}, status=status.HTTP_401_UNAUTHORIZED)

        user = serializer.validated_data['user']
        refresh = RefreshToken.for_user(user)
        response_data = {
            'message': 'Login successful.',
            'tokens': {
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            },
            'user': UserSerializer(user).data,
        }
        return Response(response_data, status=status.HTTP_200_OK)

class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        request=LogoutSerializer,
        responses={
            200: MessageResponseSerializer,
            400: ErrorResponseSerializer,
        },
    )
    def post(self, request):
        serializer = LogoutSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            refresh_token = RefreshToken(serializer.validated_data['refresh'])
            refresh_token.blacklist()
        except TokenError:
            return Response(
                {'non_field_errors': ['Invalid or expired refresh token.']},
                status=status.HTTP_400_BAD_REQUEST,
            )

        return Response({'message': 'Logged out successfully.'}, status=status.HTTP_200_OK)

class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(responses={200: UserSerializer})
    def get(self, request):
        return Response(UserSerializer(request.user).data, status=status.HTTP_200_OK)

    @extend_schema(request=UserSerializer, responses={200: UserSerializer})
    def put(self, request):
        serializer = UserSerializer(request.user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)

class ChangePasswordView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        request=ChangePasswordSerializer,
        responses={
            200: MessageResponseSerializer,
            400: ErrorResponseSerializer,
        },
    )
    def post(self, request):
        serializer = ChangePasswordSerializer(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        request.user.set_password(serializer.validated_data['new_password'])
        request.user.save(update_fields=['password'])
        return Response({'message': 'Password changed successfully.'}, status=status.HTTP_200_OK)


class DeviceTokenView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = DeviceTokenSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        request.user.fcm_token = serializer.validated_data['fcm_token'] or None
        request.user.save(update_fields=['fcm_token'])
        return Response({'message': 'Device token updated.'}, status=status.HTTP_200_OK)


def _resolve_otp_email(request, serializer):
    email = serializer.validated_data.get('email') or request.user.email
    if not email:
        return None, Response({'error': 'Email is required.'}, status=status.HTTP_400_BAD_REQUEST)
    if request.user.email and email.lower() != request.user.email.lower():
        return None, Response({'error': 'Email must match the authenticated user.'}, status=status.HTTP_400_BAD_REQUEST)
    return email, None


class OTPSendView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = OTPSendSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email, error_response = _resolve_otp_email(request, serializer)
        if error_response:
            return error_response

        code = f'{random.SystemRandom().randint(0, 999999):06d}'
        expires_at = timezone.now() + timedelta(minutes=settings.OTP_EXPIRY_MINUTES)
        OTP.objects.create(user=request.user, code=code, expires_at=expires_at)

        send_mail(
            'Your Smart Room Renting OTP',
            f'Your verification code is {code}. It expires in {settings.OTP_EXPIRY_MINUTES} minutes.',
            settings.DEFAULT_FROM_EMAIL,
            [email],
            fail_silently=False,
        )
        return Response({'message': 'OTP sent.'}, status=status.HTTP_200_OK)


class OTPVerifyView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = OTPVerifySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email, error_response = _resolve_otp_email(request, serializer)
        if error_response:
            return error_response

        otp = OTP.objects.filter(
            user=request.user,
            code=serializer.validated_data['code'],
            is_used=False,
        ).first()

        if not otp or otp.is_expired():
            return Response({'error': 'Invalid or expired OTP.'}, status=status.HTTP_400_BAD_REQUEST)

        otp.is_used = True
        otp.save(update_fields=['is_used'])
        return Response({'message': 'OTP verified.'}, status=status.HTTP_200_OK)

class AdminUserListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if not request.user.is_staff:
            raise PermissionDenied('Admin access required.')

        user_model = get_user_model()
        users = user_model.objects.all().order_by('username')
        data = UserSerializer(users, many=True).data
        return Response({'count': len(data), 'results': data}, status=status.HTTP_200_OK)

class BanUserView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request, pk):
        if not request.user.is_staff:
            raise PermissionDenied('Admin access required.')

        user_model = get_user_model()
        target = user_model.objects.filter(pk=pk).first()
        if not target:
            return Response({'error': 'User not found.'}, status=status.HTTP_404_NOT_FOUND)

        if target.id == request.user.id:
            return Response({'error': 'You cannot ban yourself.'}, status=status.HTTP_400_BAD_REQUEST)

        target.is_active = False
        target.save(update_fields=['is_active'])
        return Response({'message': 'User has been banned.'}, status=status.HTTP_200_OK)

class AdminDashboardView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if not request.user.is_staff:
            raise PermissionDenied('Admin access required.')

        user_model = get_user_model()
        data = {
            'total_users': user_model.objects.count(),
            'active_users': user_model.objects.filter(is_active=True).count(),
            'staff_users': user_model.objects.filter(is_staff=True).count(),
        }
        return Response(data, status=status.HTTP_200_OK)
