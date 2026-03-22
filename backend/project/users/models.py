from rest_framework.relations import PrimaryKeyRelatedField
from django.db import models

class User(models.Model):
    userId = models.CharField(max_length=100, primary_key=True, auto_created=True)
    name = models.CharField(max_length=100)
    email = models.EmailField(max_length=100)
    passwordHash = models.CharField(max_length=100)
    role = models.CharField(max_length=100)
    phone = models.CharField(max_length=15)
    createdAt = models.DateTimeField(auto_now_add=True)

    
# Create your models here.
