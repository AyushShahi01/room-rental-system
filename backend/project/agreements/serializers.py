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
        validated_data['content'] = self._build_content(validated_data)
        validated_data['landlord_is_signed'] = True
        validated_data['landlord_signed_at'] = timezone.now()
        return super().create(validated_data)

    def _build_content(self, data):
        lines = [
            f'Rent Price: NPR {data["rent_price"]}',
            f'Rent Mode: {dict(Agreement.RENT_MODE_CHOICES).get(data["rent_mode"], data["rent_mode"])}',
        ]

        if data['rent_mode'] == Agreement.RENT_MODE_FIXED:
            duration_label = dict(Agreement.FIXED_DURATION_TYPE_CHOICES).get(
                data.get('fixed_duration_type'),
                data.get('fixed_duration_type'),
            )
            lines.append(
                f'Fixed Duration: {data.get("fixed_duration_value")} {duration_label}'
            )
        else:
            lines.extend([
                f'Initial Rent: NPR {data.get("initial_rent")}',
                f'Increment Every: {dict(Agreement.INCREMENT_EVERY_CHOICES).get(data.get("increment_every"), data.get("increment_every"))}',
                f'Increment Type: {dict(Agreement.INCREMENT_TYPE_CHOICES).get(data.get("increment_type"), data.get("increment_type"))}',
                f'Increase By: {data.get("increase_by")}',
            ])

        if data.get('house_rules'):
            lines.extend(['', 'House Rules:', data['house_rules']])

        if data.get('additional_description'):
            lines.extend(['', 'Additional Description:', data['additional_description']])

        return '\n'.join(lines)
