from django.db import models
from django.contrib.auth.models import AbstractUser

class CustomUser(AbstractUser):
    is_landlord = models.BooleanField(default=False)
    is_tenant = models.BooleanField(default=False)
