from django.utils import timezone


def _money(value):
    if value in (None, ''):
        return 'N/A'
    return f'NPR {value}'


def generate_agreement_content(booking):
    room = booking.room
    tenant = booking.tenant
    landlord = room.landlord
    today = timezone.localdate().isoformat()

    tenant_name = tenant.get_full_name() or tenant.username
    landlord_name = landlord.get_full_name() or landlord.username

    return (
        f'Lease Agreement\n\n'
        f'Date: {today}\n\n'
        f'This agreement is made between landlord {landlord_name} and tenant {tenant_name} '
        f'for the room "{room.title}" located in ward {room.ward_number}, {room.state}, {room.province}.\n\n'
        f'Monthly Rent: {_money(room.price)}\n'
        f'Security Deposit: {_money(room.security_deposit)}\n'
        f'Maintenance Charges: {_money(room.maintenance_charges)}\n\n'
        f'The tenant agrees to follow the agreed rental terms and maintain the room responsibly. '
        f'The landlord agrees to provide the room as described in the listing.'
    )
