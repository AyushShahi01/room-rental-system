from django.db import models
from bookings.models import Booking

class Agreement(models.Model):
    booking = models.OneToOneField(Booking, on_delete=models.CASCADE)
    content = models.TextField()
    is_signed = models.BooleanField(default=False)
