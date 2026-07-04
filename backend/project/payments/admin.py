from django.contrib import admin
from .models import RentRecord


@admin.register(RentRecord)
class RentRecordAdmin(admin.ModelAdmin):
    list_display = (
        'id',
        'tenant',
        'room',
        'amount',
        'amount_paid',
        'billing_month',
        'billing_year',
        'status',
        'due_date',
    )
    list_filter = ('status', 'billing_year', 'billing_month')
    search_fields = ('tenant__username', 'room__title', 'status')
    ordering = ('-billing_year', '-billing_month', 'id')
    list_select_related = ('tenant', 'room')
