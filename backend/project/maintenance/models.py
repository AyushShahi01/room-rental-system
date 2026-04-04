from django.db import models
from django.conf import settings
from rooms.models import Room

class MaintenanceRequest(models.Model):
    tenant = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    room = models.ForeignKey(Room, on_delete=models.CASCADE)
    description = models.TextField()
    status = models.CharField(max_length=50, default='pending')
