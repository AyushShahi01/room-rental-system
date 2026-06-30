import logging

from django.conf import settings

logger = logging.getLogger(__name__)

_initialized = False


def _initialize():
    global _initialized
    if _initialized:
        return True

    if not settings.FIREBASE_CREDENTIALS_PATH:
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
        return False

    from firebase_admin import messaging

    message = messaging.Message(
        notification=messaging.Notification(title='Smart Room Renting', body=content),
        token=token,
    )
    messaging.send(message)
    return True
