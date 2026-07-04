from django.utils import timezone
from rest_framework import serializers

from bookings.models import Booking

from .models import Agreement


class AgreementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Agreement
        fields = (
            'id',
            'booking',
            'content',
            'rent_price',
            'rent_mode',
            'fixed_duration_type',
            'fixed_duration_value',
            'initial_rent',
            'increment_every',
            'increment_type',
            'increase_by',
            'house_rules',
            'additional_description',
            'landlord_is_signed',
            'landlord_signed_at',
            'is_signed',
            'signed_at',
            'created_at',
        )
        read_only_fields = (
            'id',
            'content',
            'landlord_is_signed',
            'landlord_signed_at',
            'is_signed',
            'signed_at',
            'created_at',
        )

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        from bookings.serializers import BookingSerializer
        representation['booking'] = BookingSerializer(instance.booking, context=self.context).data
        return representation

    def validate(self, attrs):
        rent_mode = attrs.get('rent_mode')
        if self.instance is not None:
            return attrs

        if rent_mode == Agreement.RENT_MODE_FIXED:
            if not attrs.get('fixed_duration_type'):
                raise serializers.ValidationError(
                    {'fixed_duration_type': 'Fixed Duration Type is required for Fixed rent mode.'}
                )
            if not attrs.get('fixed_duration_value'):
                raise serializers.ValidationError(
                    {'fixed_duration_value': 'Duration Value is required for Fixed rent mode.'}
                )
        elif rent_mode == Agreement.RENT_MODE_INCREMENT:
            missing = {}
            if attrs.get('initial_rent') is None:
                missing['initial_rent'] = 'Initial Rent is required for Increment rent mode.'
            if not attrs.get('increment_every'):
                missing['increment_every'] = 'Increment Every is required for Increment rent mode.'
            if not attrs.get('increment_type'):
                missing['increment_type'] = 'Increment Type is required for Increment rent mode.'
            if attrs.get('increase_by') is None:
                missing['increase_by'] = 'Increase By is required for Increment rent mode.'
            if missing:
                raise serializers.ValidationError(missing)

        return attrs

    def validate_booking(self, booking):
        request = self.context.get('request')
        user = getattr(request, 'user', None)

        if booking.status != Booking.STATUS_APPROVED:
            raise serializers.ValidationError('Agreement can only be created for approved bookings.')

        if user and user.is_authenticated and booking.room.landlord_id != user.id:
            raise serializers.ValidationError('Only the room landlord can create an agreement.')

        if Agreement.objects.filter(booking=booking).exists():
            raise serializers.ValidationError('An agreement already exists for this booking.')

        return booking

    def create(self, validated_data):
        from .utils import generate_agreement_content
        booking = validated_data['booking']
        validated_data['content'] = generate_agreement_content(
            booking,
            rent_price=validated_data.get('rent_price'),
            house_rules=validated_data.get('house_rules'),
            additional_description=validated_data.get('additional_description'),
        )
        validated_data['landlord_is_signed'] = True
        validated_data['landlord_signed_at'] = timezone.now()
        return super().create(validated_data)
