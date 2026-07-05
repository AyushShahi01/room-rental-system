import datetime
from django.db import transaction

def sync_rent_records_for_booking(booking):
    """
    Synchronizes RentRecord objects for an approved Booking starting from booking.rent_start_date
    up to the current calendar month and year on a monthly basis.
    """
    start_date = booking.rent_start_date
    if not start_date or booking.status != 'approved':
        return
    
    today = datetime.date.today()
    current_date = start_date
    
    # Run in a transaction to prevent partial/duplicate creates
    with transaction.atomic():
        while True:
            # If current_date's calendar month & year is in the future compared to today, we stop.
            if (current_date.year > today.year) or (current_date.year == today.year and current_date.month > today.month):
                break
            
            from payments.models import RentRecord
            exists = RentRecord.objects.filter(
                room=booking.room,
                tenant=booking.tenant,
                billing_month=current_date.month,
                billing_year=current_date.year
            ).exists()
            
            if not exists:
                RentRecord.objects.create(
                    room=booking.room,
                    tenant=booking.tenant,
                    amount=booking.room.price,
                    amount_paid=0.00,
                    billing_month=current_date.month,
                    billing_year=current_date.year,
                    due_date=current_date,
                    status=RentRecord.STATUS_UNPAID
                )
            
            # Safely increment by 1 month
            year = current_date.year
            month = current_date.month + 1
            if month > 12:
                month = 1
                year += 1
                
            # Clamp days to prevent overflow in shorter months
            day = start_date.day
            if month in [4, 6, 9, 11] and day > 30:
                day = 30
            elif month == 2:
                is_leap = year % 4 == 0 and (year % 100 != 0 or year % 400 == 0)
                if is_leap and day > 29:
                    day = 29
                elif not is_leap and day > 28:
                    day = 28
            
            try:
                current_date = datetime.date(year, month, day)
            except ValueError:
                # Fallback safeguard
                current_date = datetime.date(year, month, 28)
