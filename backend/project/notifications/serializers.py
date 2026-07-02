from rest_framework import serializers
from .models import Notification


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ('id', 'user', 'content', 'is_read', 'created_at')
        read_only_fields = ('id', 'user', 'is_read', 'created_at')

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        from users.serializers import UserSerializer
        representation['user'] = UserSerializer(instance.user, context=self.context).data
        return representation

