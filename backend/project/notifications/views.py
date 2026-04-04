from rest_framework import generics
from .models import Notification
from .serializers import NotificationSerializer
from rest_framework.views import APIView
from rest_framework.response import Response

class NotificationListView(generics.ListAPIView):
    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer

class NotificationActionView(APIView):
    def patch(self, request, pk): return Response({"message": "Mark read"})

class ReadAllNotificationsView(APIView):
    def patch(self, request): return Response({"message": "Mark all read"})

class DeleteNotificationView(generics.DestroyAPIView):
    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer
