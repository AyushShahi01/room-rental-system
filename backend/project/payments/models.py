from django.db import models
from django.conf import settings
from bookings.models import Booking


class Payment(models.Model):
    GATEWAY_KHALTI = 'khalti'
    GATEWAY_ESEWA = 'esewa'
    GATEWAY_MANUAL = 'manual'
    GATEWAY_CHOICES = (
        (GATEWAY_KHALTI, 'Khalti'),
        (GATEWAY_ESEWA, 'eSewa'),
        (GATEWAY_MANUAL, 'Manual'),
    )

    STATUS_PENDING = 'pending'
    STATUS_VERIFIED = 'verified'
    STATUS_FAILED = 'failed'
    STATUS_CHOICES = (
        (STATUS_PENDING, 'Pending'),
        (STATUS_VERIFIED, 'Verified'),
        (STATUS_FAILED, 'Failed'),
    )

    booking = models.ForeignKey(Booking, on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=50, choices=STATUS_CHOICES, default=STATUS_PENDING)
    payment_gateway = models.CharField(max_length=20, choices=GATEWAY_CHOICES, default=GATEWAY_MANUAL)
    transaction_token = models.CharField(max_length=255, null=True, blank=True)
    gateway_response = models.JSONField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'Payment {self.id} for booking {self.booking_id}'
