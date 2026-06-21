from django.db import models
from django.conf import settings
from rooms.models import Room


class MaintenanceRequest(models.Model):
    STATUS_PENDING = 'pending'
    STATUS_IN_PROGRESS = 'in_progress'
    STATUS_RESOLVED = 'resolved'
    STATUS_REJECTED = 'rejected'
    STATUS_CHOICES = (
        (STATUS_PENDING, 'Pending'),
        (STATUS_IN_PROGRESS, 'In Progress'),
        (STATUS_RESOLVED, 'Resolved'),
        (STATUS_REJECTED, 'Rejected'),
    )

    tenant = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    room = models.ForeignKey(Room, on_delete=models.CASCADE)
    description = models.TextField()
    status = models.CharField(max_length=50, choices=STATUS_CHOICES, default=STATUS_PENDING)
    image = models.ImageField(upload_to='maintenance/images/', null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'MaintenanceRequest {self.id} for room {self.room_id}'
