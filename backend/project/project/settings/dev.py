"""
Development settings — local dev with SQLite and console email.
Usage:  DJANGO_SETTINGS_MODULE=project.settings.dev python manage.py runserver
"""
from .base import *  # noqa: F401,F403

# ─── Debug ──────────────────────────────────────────────────────────────────────
DEBUG = True
ALLOWED_HOSTS = ['*']

# ─── Database (MySQL for local dev) ─────────────────────────────────────────────
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'room_rental_db',
        'USER': 'root',
        'PASSWORD': '',
        'HOST': '127.0.0.1',
        'PORT': '3306',
    }
}

# ─── CORS (allow everything in dev) ─────────────────────────────────────────────
CORS_ALLOW_ALL_ORIGINS = True

# ─── Email (print to console in dev) ────────────────────────────────────────────
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
DEFAULT_FROM_EMAIL = 'noreply@localhost'

# ─── Also allow browsable API in dev ────────────────────────────────────────────
REST_FRAMEWORK = {
    **REST_FRAMEWORK,  # type: ignore  # noqa: F405
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
        'rest_framework.renderers.BrowsableAPIRenderer',
    ],
}
