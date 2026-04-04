from rest_framework import generics
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from .serializers import RegisterSerializer

class RegisterView(generics.CreateAPIView):
    permission_classes = [AllowAny]
    serializer_class = RegisterSerializer

class LoginView(APIView):
    def post(self, request): return Response({"message": "Login"})

class LogoutView(APIView):
    def post(self, request): return Response({"message": "Logout"})

class UserProfileView(APIView):
    def get(self, request): return Response({"message": "Get profile"})
    def put(self, request): return Response({"message": "Update profile"})

class ChangePasswordView(APIView):
    def post(self, request): return Response({"message": "Change password"})

class AdminUserListView(APIView):
    def get(self, request): return Response({"message": "Admin list users"})

class BanUserView(APIView):
    def patch(self, request, pk): return Response({"message": "Ban user"})

class AdminDashboardView(APIView):
    def get(self, request): return Response({"message": "Admin dashboard"})
