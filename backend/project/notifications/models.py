from django.db import models

class Notifications(models.Model):
    notificationId = models.CharField(max_length=100, primary_key=True, auto_created=True)
    userId = models.CharField(max_length=100, foreign_key=True)
    type = models.CharField(max_length=100)
    message = models.CharField(max_length=255)
    isRead = models.BooleanField(default=False)
    createdAt = models.DateTimeField(auto_now_add=True)
# Create your models here.
