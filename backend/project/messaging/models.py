from django.db import models

class Messages(models.Model):
    messageId = models.CharField(max_length=100, primary_key=True, auto_created=True)
    senderId = models.CharField(max_length=100, foreign_key=True)
    receiverId = models.CharField(max_length=100, foreign_key=True)
    message = models.CharField(max_length=255)
    createdAt = models.DateTimeField(auto_now_add=True)
    readAt = models.DateTimeField(null=True, blank=True)
# Create your models here.
