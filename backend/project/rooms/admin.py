from django.contrib import admin

from .models import Room, RoomImage


@admin.register(Room)
class RoomAdmin(admin.ModelAdmin):
	list_display = ('id', 'title', 'landlord', 'province', 'state', 'ward_number', 'price', 'is_available', 'created_at')
	list_filter = ('is_available', 'furnished_status', 'has_wifi', 'has_ac', 'parking_available', 'food_available', 'water_supply_available', 'waste_collection_available', 'gender_preference')
	search_fields = ('title', 'description', 'province', 'state', 'landlord__username', 'landlord__email')
	ordering = ('id',)
	list_select_related = ('landlord',)


@admin.register(RoomImage)
class RoomImageAdmin(admin.ModelAdmin):
	list_display = ('id', 'room', 'created_at')
	search_fields = ('room__title', 'room__landlord__username')
	ordering = ('id',)
	list_select_related = ('room',)
