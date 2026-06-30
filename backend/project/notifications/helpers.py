import logging

from .firebase import send_push
from .models import Notification

logger = logging.getLogger(__name__)


def create_notification(user, content):
    notification = Notification.objects.create(user=user, content=content)

    token = getattr(user, 'fcm_token', None)
    if token:
        try:
            send_push(token, content)
        except Exception as exc:
            if exc.__class__.__name__ in {'UnregisteredError', 'InvalidArgumentError'}:
                user.fcm_token = None
                user.save(update_fields=['fcm_token'])
            else:
                logger.exception('Failed to send push notification.')

    return notification
