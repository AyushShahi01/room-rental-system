from django.contrib import admin

from .models import Booking


@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
	list_display = ('id', 'tenant', 'room', 'status')
	list_filter = ('status',)
	search_fields = (
		'tenant__username',
		'tenant__email',
		'room__title',
		'status',
	)
	ordering = ('id',)
	list_select_related = ('tenant', 'room')
