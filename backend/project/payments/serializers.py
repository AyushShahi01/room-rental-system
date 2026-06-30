from rest_framework import serializers
from .models import Payment


class PaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Payment
        fields = (
            'id',
            'booking',
            'amount',
            'status',
            'payment_gateway',
            'transaction_token',
            'gateway_response',
            'created_at',
        )
        read_only_fields = ('id', 'status', 'transaction_token', 'gateway_response', 'created_at')

    def validate(self, attrs):
        request = self.context.get('request')
        user = getattr(request, 'user', None)
        booking = attrs.get('booking')
        amount = attrs.get('amount')

        if amount is not None and amount <= 0:
            raise serializers.ValidationError({'amount': ['Amount must be greater than zero.']})

        if user and user.is_authenticated and booking and booking.tenant_id != user.id:
            raise serializers.ValidationError({'booking': ['You can only create payments for your own bookings.']})

        return attrs
