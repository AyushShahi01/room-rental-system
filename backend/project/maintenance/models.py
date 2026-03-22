from django.db import models

class Maintenance(models.Model):
    maintenanceId = models.CharField(max_length=100, primary_key=True, auto_created=True)
    roomId = models.CharField(max_length=100, foreign_key=True)
    userId = models.CharField(max_length=100, foreign_key=True)
    description = models.CharField(max_length=255)
    status = models.CharField(max_length=100)
    dateReported = models.DateTimeField(auto_now_add=True)
    dateResolved = models.DateTimeField(null=True, blank=True)
    
# Create your models here.
