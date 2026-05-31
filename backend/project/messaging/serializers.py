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
        booking_id = attrs.get('booking_id')

        if receiver and user and receiver.id == user.id:
            raise serializers.ValidationError({'receiver': ['You cannot message yourself.']})

        if booking_id is not None:
            booking = Booking.objects.filter(id=booking_id).select_related('tenant', 'room__landlord').first()
            if not booking:
                raise serializers.ValidationError({'booking_id': ['Booking not found.']})

            participants = {booking.tenant_id, booking.room.landlord_id}
            if user and user.id not in participants:
                raise serializers.ValidationError({'booking_id': ['You are not part of this booking conversation.']})
            if receiver and receiver.id not in participants:
                raise serializers.ValidationError({'receiver': ['Receiver must belong to this booking conversation.']})

        return attrs
