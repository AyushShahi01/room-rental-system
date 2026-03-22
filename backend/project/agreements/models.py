from django.db import models

class Agreements(models.Model):
    agreementId = models.CharField(max_length=100, primary_key=True, auto_created=True)
    bookingId = models.CharField(max_length=100, foreign_key=True)
    agreementUrl = models.CharField(max_length=255)
    status = models.CharField(max_length=100)
    createdAt = models.DateTimeField(auto_now_add=True)
    landlordSigned = models.BooleanField(default=False)
    tenantSigned = models.BooleanField(default=False)
# Create your models here.
