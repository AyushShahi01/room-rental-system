from rest_framework import serializers
from .models import Booking


class BookingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Booking
        fields = ('id', 'tenant', 'room', 'status', 'created_at')
        read_only_fields = ('id', 'tenant', 'status', 'created_at')

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        from rooms.serializers import RoomSerializer
        from users.serializers import UserSerializer
        
        representation['room'] = RoomSerializer(instance.room, context=self.context).data
        representation['tenant'] = UserSerializer(instance.tenant, context=self.context).data
        return representation

    def validate_room(self, room):
        request = self.context.get('request')
        user = getattr(request, 'user', None)

        if not room.is_available:
            raise serializers.ValidationError('This room is not currently available for booking.')

        if user and user.is_authenticated and room.landlord_id == user.id:
            raise serializers.ValidationError('You cannot book your own room.')

        return room
