from django.db import models
from django.conf import settings
from django.utils import timezone
from rooms.models import Room


class RentRecord(models.Model):
    STATUS_PAID = 'paid'
    STATUS_UNPAID = 'unpaid'
    STATUS_PARTIALLY_PAID = 'partially_paid'
    STATUS_OVERDUE = 'overdue'
    STATUS_PENDING = 'pending'

    STATUS_CHOICES = (
        (STATUS_PAID, 'Paid'),
        (STATUS_UNPAID, 'Unpaid'),
        (STATUS_PARTIALLY_PAID, 'Partially Paid'),
        (STATUS_OVERDUE, 'Overdue'),
        (STATUS_PENDING, 'Pending Verification'),
    )

    tenant = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='rent_records')
    room = models.ForeignKey(Room, on_delete=models.CASCADE, related_name='rent_records')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    amount_paid = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    billing_month = models.PositiveIntegerField()  # 1 to 12
    billing_year = models.PositiveIntegerField()
    due_date = models.DateField()
    payment_date = models.DateField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default=STATUS_UNPAID)
    remarks = models.TextField(blank=True, default='')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ('-billing_year', '-billing_month', '-created_at')

    def __str__(self):
        return f'Rent for Room {self.room_id} - Tenant {self.tenant_id} ({self.billing_month}/{self.billing_year})'

    @classmethod
    def update_overdue(cls):
        """
        Updates status to 'overdue' for any unpaid/partially paid records whose due_date is in the past.
        """
        now_date = timezone.now().date()
        cls.objects.filter(
            status__in=[cls.STATUS_UNPAID, cls.STATUS_PARTIALLY_PAID],
            due_date__lt=now_date
        ).update(status=cls.STATUS_OVERDUE)
