from rest_framework import generics, status
from .models import Message
from .serializers import MessageSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from django.db.models import Q
from users.serializers import UserSerializer
from notifications.helpers import create_notification

class MessageListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = MessageSerializer

    def get_queryset(self):
        user = self.request.user
        queryset = Message.objects.filter(Q(sender=user) | Q(receiver=user))
        recipient_id = self.request.query_params.get('recipient_id')
        if recipient_id:
            queryset = queryset.filter(Q(sender=user, receiver_id=recipient_id) | Q(sender_id=recipient_id, receiver=user))
        return queryset.order_by('created_at')

    def perform_create(self, serializer):
        message = serializer.save(sender=self.request.user)
        create_notification(message.receiver, f'New message from {message.sender.username}.')

class MessageDetailView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = MessageSerializer

    def get_queryset(self):
        user = self.request.user
        return Message.objects.filter(Q(sender=user) | Q(receiver=user)).order_by('created_at')

class BookingMessagesView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = MessageSerializer

    def get_queryset(self):
        user = self.request.user
        booking_id = self.kwargs['booking_id']
        return Message.objects.filter(booking_id=booking_id).filter(Q(sender=user) | Q(receiver=user)).order_by('created_at')


class ConversationListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        messages = Message.objects.filter(Q(sender=user) | Q(receiver=user)).select_related('sender', 'receiver').order_by('-created_at')
        conversations = []
        seen = set()

        for message in messages:
            partner = message.receiver if message.sender_id == user.id else message.sender
            if partner.id in seen:
                continue
            seen.add(partner.id)
            conversations.append({
                'partner': UserSerializer(partner).data,
                'latest_message': MessageSerializer(message).data,
            })

        return Response({'count': len(conversations), 'results': conversations}, status=status.HTTP_200_OK)

class MarkMessageReadView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request, pk):
        message = get_object_or_404(Message, pk=pk, receiver=request.user)
        if message.is_read:
            return Response({'message': 'Message already marked as read.'}, status=status.HTTP_200_OK)

        message.is_read = True
        message.save(update_fields=['is_read'])
        return Response({'message': 'Message marked as read.'}, status=status.HTTP_200_OK)
