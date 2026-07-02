# pyrefly: ignore [missing-import]
from rest_framework import serializers
from .models import Booking


class BookingSerializer(serializers.ModelSerializer):
    # Read-only enriched fields so the frontend gets real names
    room_id = serializers.IntegerField(source='room.id', read_only=True)
    room_title = serializers.CharField(source='room.title', read_only=True)
    room_price = serializers.CharField(source='room.price', read_only=True)
    room_province = serializers.CharField(source='room.province', read_only=True)
    room_state = serializers.CharField(source='room.state', read_only=True)

    tenant_id = serializers.CharField(source='tenant.id', read_only=True)
    tenant_name = serializers.SerializerMethodField()

    landlord_id = serializers.CharField(source='room.landlord.id', read_only=True)
    landlord_name = serializers.SerializerMethodField()

    # Write-only: accept room as an integer primary key when creating
    room = serializers.PrimaryKeyRelatedField(
        queryset=__import__('rooms.models', fromlist=['Room']).Room.objects.all(),
        write_only=True,
    )

    class Meta:
        model = Booking
        fields = (
            'id',
            'status',
            'created_at',
            # write-only
            'room',
            # read-only enriched
            'room_id',
            'room_title',
            'room_price',
            'room_province',
            'room_state',
            'tenant_id',
            'tenant_name',
            'landlord_id',
            'landlord_name',
        )
        read_only_fields = ('id', 'status', 'created_at')

    def get_tenant_name(self, obj):
        user = obj.tenant
        if not user:
            return None
        return user.username or (
            f'{user.first_name} {user.last_name}'.strip() or None
        ) or str(user.id)

    def get_landlord_name(self, obj):
        landlord = obj.room.landlord if obj.room else None
        if not landlord:
            return None
        return landlord.username or (
            f'{landlord.first_name} {landlord.last_name}'.strip() or None
        ) or str(landlord.id)

    def validate_room(self, room):
        request = self.context.get('request')
        user = getattr(request, 'user', None)

        if not room.is_available:
            raise serializers.ValidationError('This room is not currently available for booking.')

        if user and user.is_authenticated and room.landlord_id == user.id:
            raise serializers.ValidationError('You cannot book your own room.')

        return room
