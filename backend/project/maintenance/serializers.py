from rest_framework import serializers
from .models import MaintenanceRequest


class MaintenanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = MaintenanceRequest
        fields = ('id', 'tenant', 'room', 'description', 'status', 'image', 'created_at')
        read_only_fields = ('id', 'tenant', 'status', 'created_at')

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        from rooms.serializers import RoomSerializer
        from users.serializers import UserSerializer
        
        representation['room'] = RoomSerializer(instance.room, context=self.context).data
        representation['tenant'] = UserSerializer(instance.tenant, context=self.context).data
        return representation

    def validate_description(self, value):
        cleaned = value.strip()
        if not cleaned:
            raise serializers.ValidationError('Description cannot be empty.')
        return cleaned


class MaintenanceImageUploadSerializer(serializers.Serializer):
    image = serializers.ImageField(required=True)

