from rest_framework import serializers
from .models import Message
from bookings.models import Booking


class MessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Message
        fields = ('id', 'sender', 'receiver', 'content', 'is_read', 'booking_id', 'created_at')
        read_only_fields = ('id', 'sender', 'is_read', 'created_at')

    def validate(self, attrs):
        request = self.context.get('request')
        user = getattr(request, 'user', None)
        receiver = attrs.get('receiver')

        if receiver and user and receiver.id == user.id:
            raise serializers.ValidationError({'receiver': ['You cannot message yourself.']})

        return attrs
