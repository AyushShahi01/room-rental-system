from django.contrib import admin

from .models import Payment


@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
	list_display = ('id', 'booking', 'amount', 'status')
	list_filter = ('status',)
	search_fields = ('booking__id', 'status')
	ordering = ('id',)
	list_select_related = ('booking',)
