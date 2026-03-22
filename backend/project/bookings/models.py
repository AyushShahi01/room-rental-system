from django.db import models

class Bookings(models.Model):
    bookingId = models.CharField(max_length=100, primary_key=True, auto_created=True)
    roomId = models.CharField(max_length=100, foreign_key=True)
    userId = models.CharField(max_length=100, foreign_key=True)
    startDate = models.DateField()
    endDate = models.DateField()
    totalPrice = models.IntegerField()
    status = models.CharField(max_length=100)
    createdAt = models.DateTimeField(auto_now_add=True)
# Create your models here.
