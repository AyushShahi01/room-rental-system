import logging

from django.conf import settings

logger = logging.getLogger(__name__)

_initialized = False


def _initialize():
    global _initialized
    if _initialized:
        return True

    if not settings.FIREBASE_CREDENTIALS_PATH:
        logger.error(
            'FCM is not configured: set FIREBASE_CREDENTIALS_PATH to the '
            'Firebase Admin service-account JSON file.'
        )
        return False

    try:
        import firebase_admin
        from firebase_admin import credentials

        if not firebase_admin._apps:
            cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
            firebase_admin.initialize_app(cred)
        _initialized = True
        return True
    except Exception:
        logger.exception('Firebase initialization failed.')
        return False


def send_push(token, content):
    if not token or not _initialize():
        if not token:
            logger.warning('Skipping FCM notification because the user has no device token.')
        return False

    from firebase_admin import messaging

    message = messaging.Message(
        notification=messaging.Notification(title='Smart Room Renting', body=content),
        data={'type': 'notification'},
        android=messaging.AndroidConfig(
            priority='high',
            notification=messaging.AndroidNotification(
                channel_id='high_importance_channel',
                sound='default',
            ),
        ),
        token=token,
    )
    message_id = messaging.send(message)
    logger.info('FCM notification sent: message_id=%s', message_id)
    return True
