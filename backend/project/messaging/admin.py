from django.contrib import admin

from .models import Message


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
	list_display = ('id', 'sender', 'receiver', 'is_read', 'booking_id')
	list_filter = ('is_read',)
	search_fields = (
		'sender__username',
		'sender__email',
		'receiver__username',
		'receiver__email',
		'content',
		'booking_id',
	)
	ordering = ('id',)
	list_select_related = ('sender', 'receiver')
