"""
Development settings — local dev with SQLite and console email.
Usage:  DJANGO_SETTINGS_MODULE=project.settings.dev python manage.py runserver
"""
import dj_database_url

from .base import *  # noqa: F401,F403

# ─── Debug ──────────────────────────────────────────────────────────────────────
DEBUG = True
ALLOWED_HOSTS = ['*']

# ─── Database (local dev) ────────────────────────────────────────────────────────
DATABASES = {
    'default': dj_database_url.parse(
        os.environ.get("DATABASE_URL", "postgresql://neondb_owner:npg_wQil81hkJFBG@ep-damp-king-ani3ksii-pooler.c-6.us-east-1.aws.neon.tech/room-rental?sslmode=require&channel_binding=require")
    )
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
