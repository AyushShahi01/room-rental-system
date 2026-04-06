from django.contrib import admin

from .models import Agreement


@admin.register(Agreement)
class AgreementAdmin(admin.ModelAdmin):
	list_display = ('id', 'booking', 'is_signed')
	list_filter = ('is_signed',)
	search_fields = ('booking__id', 'content')
	ordering = ('id',)
	list_select_related = ('booking',)
