from rest_framework import generics
from .models import Message
from .serializers import MessageSerializer
from rest_framework.views import APIView
from rest_framework.response import Response

class MessageListCreateView(generics.ListCreateAPIView):
    queryset = Message.objects.all()
    serializer_class = MessageSerializer

class MessageDetailView(generics.RetrieveAPIView):
    queryset = Message.objects.all()
    serializer_class = MessageSerializer

class BookingMessagesView(generics.ListAPIView):
    serializer_class = MessageSerializer
    def get_queryset(self): return Message.objects.filter(booking_id=self.kwargs['booking_id'])

class MarkMessageReadView(APIView):
    def patch(self, request, pk): return Response({"message": "Mark read"})
