import requests
from django.conf import settings


class EsewaGatewayError(Exception):
    pass


def check_transaction_status(transaction_uuid, total_amount):
    base_url = settings.ESEWA_API_BASE_URL.rstrip('/')
    response = requests.get(
        f'{base_url}/api/epay/transaction/status/',
        params={
            'product_code': settings.ESEWA_PRODUCT_CODE,
            'total_amount': total_amount,
            'transaction_uuid': transaction_uuid,
        },
        timeout=15,
    )

    try:
        payload = response.json()
    except ValueError as exc:
        raise EsewaGatewayError('eSewa returned an invalid response.') from exc

    if response.status_code >= 400:
        raise EsewaGatewayError(payload)

    return payload
