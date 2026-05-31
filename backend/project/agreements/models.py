from django.db import models
from bookings.models import Booking

class Agreement(models.Model):
    booking = models.OneToOneField(Booking, on_delete=models.CASCADE)
    content = models.TextField()
    is_signed = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    signed_at = models.DateTimeField(null=True, blank=True)
