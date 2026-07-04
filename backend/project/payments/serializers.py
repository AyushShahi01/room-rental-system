from django.utils import timezone
from rest_framework import serializers
from .models import RentRecord


class RentRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = RentRecord
        fields = (
            'id',
            'tenant',
            'room',
            'amount',
            'amount_paid',
            'billing_month',
            'billing_year',
            'due_date',
            'payment_date',
            'status',
            'remarks',
            'created_at',
            'updated_at',
        )
        read_only_fields = ('id', 'created_at', 'updated_at')

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        from users.serializers import UserSerializer
        from rooms.serializers import RoomSerializer
        representation['tenant'] = UserSerializer(instance.tenant, context=self.context).data
        representation['room'] = RoomSerializer(instance.room, context=self.context).data
        return representation

    def validate(self, attrs):
        # Retrieve values for validation, checking instance defaults if not provided
        amount = attrs.get('amount')
        amount_paid = attrs.get('amount_paid')
        billing_month = attrs.get('billing_month')
        billing_year = attrs.get('billing_year')
        due_date = attrs.get('due_date')
        payment_date = attrs.get('payment_date')
        status = attrs.get('status')

        if self.instance:
            if amount is None:
                amount = self.instance.amount
            if amount_paid is None:
                amount_paid = self.instance.amount_paid
            if billing_month is None:
                billing_month = self.instance.billing_month
            if billing_year is None:
                billing_year = self.instance.billing_year
            if due_date is None:
                due_date = self.instance.due_date
            if payment_date is None:
                payment_date = self.instance.payment_date
            if status is None:
                status = self.instance.status
        else:
            if amount_paid is None:
                amount_paid = 0.00

        # Field validations
        if amount is not None and amount <= 0:
            raise serializers.ValidationError({'amount': 'Rent amount must be greater than zero.'})

        if amount_paid is not None:
            if amount_paid < 0:
                raise serializers.ValidationError({'amount_paid': 'Amount paid cannot be negative.'})
            if amount is not None and amount_paid > amount:
                raise serializers.ValidationError({'amount_paid': 'Amount paid cannot exceed total rent amount.'})

        if billing_month is not None and (billing_month < 1 or billing_month > 12):
            raise serializers.ValidationError({'billing_month': 'Billing month must be between 1 and 12.'})

        if billing_year is not None and billing_year < 2000:
            raise serializers.ValidationError({'billing_year': 'Billing year must be 2000 or later.'})

        # Auto-determination of status and dates
        now_date = timezone.now().date()

        # If amount_paid is fully paid, force paid status
        if amount_paid == amount:
            attrs['status'] = RentRecord.STATUS_PAID
            if not payment_date:
                attrs['payment_date'] = now_date
        # If amount_paid is partially paid
        elif amount_paid > 0:
            attrs['status'] = RentRecord.STATUS_PARTIALLY_PAID
            # payment_date is optional here, but keep if set
        # If amount_paid is 0
        else:
            if due_date and due_date < now_date:
                attrs['status'] = RentRecord.STATUS_OVERDUE
            else:
                attrs['status'] = RentRecord.STATUS_UNPAID
            attrs['payment_date'] = None

        # Override/force paid status if user explicitly requested 'paid' but amount_paid is not updated
        if status == RentRecord.STATUS_PAID and attrs.get('status') != RentRecord.STATUS_PAID:
            attrs['status'] = RentRecord.STATUS_PAID
            attrs['amount_paid'] = amount
            if not payment_date:
                attrs['payment_date'] = now_date

        return attrs
