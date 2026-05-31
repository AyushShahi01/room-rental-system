from rest_framework import serializers
from .models import Agreement
from bookings.models import Booking


class AgreementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Agreement
        fields = ('id', 'booking', 'content', 'is_signed', 'created_at', 'signed_at')
        read_only_fields = ('id', 'is_signed', 'created_at', 'signed_at')

    def validate_booking(self, booking):
        request = self.context.get('request')
        user = getattr(request, 'user', None)

        if booking.status != Booking.STATUS_APPROVED:
            raise serializers.ValidationError('Agreement can only be created for approved bookings.')

        if user and user.is_authenticated and booking.room.landlord_id != user.id:
            raise serializers.ValidationError('Only the room landlord can create an agreement.')

        return booking
