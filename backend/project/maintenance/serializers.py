from rest_framework import serializers
from .models import MaintenanceRequest

class MaintenanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = MaintenanceRequest
        fields = '__all__'
