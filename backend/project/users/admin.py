from django.contrib import admin
from django.contrib.auth.admin import UserAdmin

from .models import CustomUser


@admin.register(CustomUser)
class CustomUserAdmin(UserAdmin):
	list_display = (
		'id',
		'username',
		'email',
		'first_name',
		'last_name',
		'role',
		'is_staff',
		'is_active',
	)
	list_filter = UserAdmin.list_filter + ('role',)
	search_fields = ('username', 'email', 'first_name', 'last_name')
	ordering = ('id',)

	fieldsets = UserAdmin.fieldsets + (
		('Role', {'fields': ('role',)}),
	)
	add_fieldsets = UserAdmin.add_fieldsets + (
		('Role', {'fields': ('role',)}),
	)
