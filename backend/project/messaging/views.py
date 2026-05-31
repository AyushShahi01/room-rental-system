from rest_framework import generics, status
from .models import Message
from .serializers import MessageSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404

class MessageListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = MessageSerializer

    def get_queryset(self):
        user = self.request.user
        return Message.objects.filter(sender=user) | Message.objects.filter(receiver=user)

    def perform_create(self, serializer):
        serializer.save(sender=self.request.user)

class MessageDetailView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = MessageSerializer

    def get_queryset(self):
        user = self.request.user
        return Message.objects.filter(sender=user) | Message.objects.filter(receiver=user)

class BookingMessagesView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = MessageSerializer

    def get_queryset(self):
        user = self.request.user
        booking_id = self.kwargs['booking_id']
        return Message.objects.filter(booking_id=booking_id).filter(sender=user) | Message.objects.filter(
            booking_id=booking_id,
            receiver=user,
        )

class MarkMessageReadView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request, pk):
        message = get_object_or_404(Message, pk=pk, receiver=request.user)
        if message.is_read:
            return Response({'message': 'Message already marked as read.'}, status=status.HTTP_200_OK)

        message.is_read = True
        message.save(update_fields=['is_read'])
        return Response({'message': 'Message marked as read.'}, status=status.HTTP_200_OK)
