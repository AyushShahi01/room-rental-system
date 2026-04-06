from django.contrib import admin

from .models import MaintenanceRequest


@admin.register(MaintenanceRequest)
class MaintenanceRequestAdmin(admin.ModelAdmin):
	list_display = ('id', 'tenant', 'room', 'status')
	list_filter = ('status',)
	search_fields = (
		'tenant__username',
		'tenant__email',
		'room__title',
		'description',
		'status',
	)
	ordering = ('id',)
	list_select_related = ('tenant', 'room')
