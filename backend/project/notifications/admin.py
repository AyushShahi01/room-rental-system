from django.contrib import admin

from .models import Notification


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
	list_display = ('id', 'user', 'is_read')
	list_filter = ('is_read',)
	search_fields = ('user__username', 'user__email', 'content')
	ordering = ('id',)
	list_select_related = ('user',)
