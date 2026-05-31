from rest_framework import serializers
from .models import Booking


class BookingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Booking
        fields = ('id', 'tenant', 'room', 'status', 'created_at')
        read_only_fields = ('id', 'tenant', 'status', 'created_at')

    def validate_room(self, room):
        request = self.context.get('request')
        user = getattr(request, 'user', None)

        if not room.is_available:
            raise serializers.ValidationError('This room is not currently available for booking.')

        if user and user.is_authenticated and room.landlord_id == user.id:
            raise serializers.ValidationError('You cannot book your own room.')

        return room
