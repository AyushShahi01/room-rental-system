import requests
from django.conf import settings


class KhaltiGatewayError(Exception):
    pass


def lookup_payment(pidx):
    if not settings.KHALTI_SECRET_KEY:
        raise KhaltiGatewayError('KHALTI_SECRET_KEY is not configured.')

    base_url = settings.KHALTI_API_BASE_URL.rstrip('/')
    response = requests.post(
        f'{base_url}/epayment/lookup/',
        json={'pidx': pidx},
        headers={
            'Authorization': f'Key {settings.KHALTI_SECRET_KEY}',
            'Content-Type': 'application/json',
        },
        timeout=15,
    )

    try:
        payload = response.json()
    except ValueError as exc:
        raise KhaltiGatewayError('Khalti returned an invalid response.') from exc

    if response.status_code >= 400:
        raise KhaltiGatewayError(payload)

    return payload
