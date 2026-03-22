from django.db import models
class Payments(models.Model):
    paymentId = models.CharField(max_length=100, primary_key=True, auto_created=True)
    bookingId = models.CharField(max_length=100, foreign_key=True)
    amount = models.IntegerField()
    paymentDate = models.DateTimeField(auto_now_add=True)
    paymentStatus = models.CharField(max_length=100)
    paymentMethod = models.CharField(max_length=100)
    transactionId = models.CharField(max_length=100)
# Create your models here.
