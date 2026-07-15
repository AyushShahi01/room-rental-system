from django.db import models
from django.conf import settings


class Room(models.Model):
    GENDER_PREFERENCE_ANY = 'any'
    GENDER_PREFERENCE_MALE = 'male'
    GENDER_PREFERENCE_FEMALE = 'female'
    GENDER_PREFERENCE_CHOICES = (
        (GENDER_PREFERENCE_ANY, 'Any'),
        (GENDER_PREFERENCE_MALE, 'Male'),
        (GENDER_PREFERENCE_FEMALE, 'Female'),
    )

    landlord = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    title = models.CharField(max_length=255)
    description = models.TextField()
    price = models.DecimalField(max_digits=10, decimal_places=2)
    province = models.CharField(max_length=100)
    state = models.CharField(max_length=100)
    ward_number = models.PositiveIntegerField()
    furnished_status = models.BooleanField(default=False)
    area_sqft = models.PositiveIntegerField(null=True, blank=True)
    security_deposit = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    maintenance_charges = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    has_wifi = models.BooleanField(default=False)
    has_ac = models.BooleanField(default=False)
    has_attached_bathroom = models.BooleanField(default=False)
    parking_available = models.BooleanField(default=False)
    food_available = models.BooleanField(default=False)
    gender_preference = models.CharField(
        max_length=10,
        choices=GENDER_PREFERENCE_CHOICES,
        default=GENDER_PREFERENCE_ANY,
    )
    water_supply_available = models.BooleanField(default=False)
    waste_collection_available = models.BooleanField(default=False)
    is_available = models.BooleanField(default=True)

    # Geographic coordinates — set by landlord when posting a room
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)

    agreement_policy = models.TextField(blank=True, default='')

    # Room agreement template defaults
    rent_mode = models.CharField(max_length=20, default='fixed')
    fixed_duration_type = models.CharField(max_length=10, null=True, blank=True, default='months')
    fixed_duration_value = models.PositiveIntegerField(null=True, blank=True)
    initial_rent = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    increment_every = models.CharField(max_length=20, null=True, blank=True, default='monthly')
    increment_type = models.CharField(max_length=20, null=True, blank=True, default='fixed_amount')
    increase_by = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    house_rules = models.TextField(blank=True, default='')
    additional_description = models.TextField(blank=True, default='')

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f'{self.title} ({self.landlord})'

    def save(self, *args, **kwargs):
        from django.core.cache import cache
        cache.delete("room_locations_list")
        super().save(*args, **kwargs)

    def delete(self, *args, **kwargs):
        from django.core.cache import cache
        cache.delete("room_locations_list")
        super().delete(*args, **kwargs)



class RoomImage(models.Model):
    room = models.ForeignKey(Room, on_delete=models.CASCADE, related_name='images')
    image = models.ImageField(upload_to='rooms/images/')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ('-created_at', '-id')

    def __str__(self):
        return f'Image {self.id} for room {self.room_id}'
