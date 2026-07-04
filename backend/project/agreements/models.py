from django.db import models
from bookings.models import Booking


class Agreement(models.Model):
    RENT_MODE_FIXED = 'fixed'
    RENT_MODE_INCREMENT = 'increment'
    RENT_MODE_CHOICES = [
        (RENT_MODE_FIXED, 'Fixed'),
        (RENT_MODE_INCREMENT, 'Increment'),
    ]

    FIXED_DURATION_MONTHS = 'months'
    FIXED_DURATION_YEARS = 'years'
    FIXED_DURATION_TYPE_CHOICES = [
        (FIXED_DURATION_MONTHS, 'Months'),
        (FIXED_DURATION_YEARS, 'Years'),
    ]

    INCREMENT_EVERY_MONTHLY = 'monthly'
    INCREMENT_EVERY_3_MONTHS = 'every_3_months'
    INCREMENT_EVERY_6_MONTHS = 'every_6_months'
    INCREMENT_EVERY_YEARLY = 'yearly'
    INCREMENT_EVERY_CHOICES = [
        (INCREMENT_EVERY_MONTHLY, 'Monthly'),
        (INCREMENT_EVERY_3_MONTHS, 'Every 3 Months'),
        (INCREMENT_EVERY_6_MONTHS, 'Every 6 Months'),
        (INCREMENT_EVERY_YEARLY, 'Yearly'),
    ]

    INCREMENT_TYPE_FIXED_AMOUNT = 'fixed_amount'
    INCREMENT_TYPE_PERCENTAGE = 'percentage'
    INCREMENT_TYPE_CHOICES = [
        (INCREMENT_TYPE_FIXED_AMOUNT, 'Fixed Amount'),
        (INCREMENT_TYPE_PERCENTAGE, 'Percentage'),
    ]

    booking = models.OneToOneField(Booking, on_delete=models.CASCADE)
    content = models.TextField(blank=True, default='')
    rent_price = models.DecimalField(max_digits=10, decimal_places=2)
    rent_mode = models.CharField(max_length=20, choices=RENT_MODE_CHOICES)
    fixed_duration_type = models.CharField(
        max_length=10,
        choices=FIXED_DURATION_TYPE_CHOICES,
        null=True,
        blank=True,
    )
    fixed_duration_value = models.PositiveIntegerField(null=True, blank=True)
    initial_rent = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    increment_every = models.CharField(
        max_length=20,
        choices=INCREMENT_EVERY_CHOICES,
        null=True,
        blank=True,
    )
    increment_type = models.CharField(
        max_length=20,
        choices=INCREMENT_TYPE_CHOICES,
        null=True,
        blank=True,
    )
    increase_by = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    house_rules = models.TextField(blank=True, default='')
    additional_description = models.TextField(blank=True, default='')
    landlord_is_signed = models.BooleanField(default=False)
    landlord_signed_at = models.DateTimeField(null=True, blank=True)
    is_signed = models.BooleanField(default=False)
    signed_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
