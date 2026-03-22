from django.db import models

class Rooms(models.Model):
    roomId = models.CharField(max_length=100, primary_key=True, auto_created=True)
    landloardId = models.CharField(max_length=100, foreign_key=True)
    description = moedls.Charfield(max_length=255, null=True)
    location = models.CharField(max_length=100)
    rentPrice = models.IntegerField()
    isAvailable = models.BooleanField(default=True)
    photoUrl = models.CharField(max_length=255)
    amenities = models.CharField(max_length=255)
    createdAt = models.DateTimeField(auto_now_add=True)
    
# Create your models here.
