from rest_framework import serializers
from .models import MaintenanceRequest


class MaintenanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = MaintenanceRequest
        fields = ('id', 'tenant', 'room', 'description', 'status', 'image', 'created_at')
        read_only_fields = ('id', 'tenant', 'status', 'created_at')

    def validate_description(self, value):
        cleaned = value.strip()
        if not cleaned:
            raise serializers.ValidationError('Description cannot be empty.')
        return cleaned
