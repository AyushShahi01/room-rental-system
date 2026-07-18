"""
Django settings for project.

Consolidated settings combining configurations from base.py, dev.py, and prod.py.
Uses python-dotenv to load environment variables from the .env file.
"""
import os
from pathlib import Path
from datetime import timedelta
import dj_database_url
from dotenv import load_dotenv
import environ

# ─── Path Config ────────────────────────────────────────────────────────────────
# BASE_DIR points to the project root (where manage.py lives)
BASE_DIR = Path(__file__).resolve().parent.parent

# Load .env file automatically
load_dotenv(os.path.join(BASE_DIR, '.env'))

# Initialize django-environ
env = environ.Env()

# ─── Debug & Security ───────────────────────────────────────────────────────────
DEBUG = os.environ.get('DEBUG', 'True').lower() in ('true', '1', 't')

if DEBUG:
    SECRET_KEY = os.environ.get(
        'DJANGO_SECRET_KEY',
        'django-insecure-change-me-in-production'
    )
    ALLOWED_HOSTS = ['*']
else:
    SECRET_KEY = os.environ['DJANGO_SECRET_KEY']
    allowed_hosts_env = os.environ.get('ALLOWED_HOSTS', '')
    ALLOWED_HOSTS = allowed_hosts_env.split(',') if allowed_hosts_env else ['*']

# ─── Application Definition ────────────────────────────────────────────────────
INSTALLED_APPS = [
    'daphne',
    'channels',
    'notifications',
    'messaging',
    'maintenance',
    'agreements',
    'payments',
    'bookings',
    'rooms',
    'drf_spectacular',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # Third-party packages
    'rest_framework',
    'rest_framework_simplejwt',
    'rest_framework_simplejwt.token_blacklist',  # Required for logout / token blacklisting
    'corsheaders',
    'storages',
    'anymail',

    # Local apps
    'users',
    'maps',
]

# ─── Custom User Model ─────────────────────────────────────────────────────────
AUTH_USER_MODEL = 'users.CustomUser'

# ─── Middleware ─────────────────────────────────────────────────────────────────
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',  # Must be before CommonMiddleware
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',

    'whitenoise.middleware.WhiteNoiseMiddleware'
]

ROOT_URLCONF = 'project.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'project.wsgi.application'
ASGI_APPLICATION = 'project.asgi.application'

CHANNEL_LAYERS = {
    "default": {
        "BACKEND": "channels.layers.InMemoryChannelLayer"
    }
}

# ─── Database ──────────────────────────────────────────────────────────────────
# Pull connection string from environment (or .env file)
DATABASE_URL = os.environ.get('DATABASE_URL')

if DATABASE_URL:
    DATABASES = {
        'default': dj_database_url.parse(DATABASE_URL)
    }
else:
    # Fallback to local PostgreSQL using individual variables if available, otherwise SQLite
    db_name = os.environ.get('DB_NAME')
    db_user = os.environ.get('DB_USER')
    db_password = os.environ.get('DB_PASSWORD')
    db_host = os.environ.get('DB_HOST', 'localhost')
    db_port = os.environ.get('DB_PORT', '5432')

    if db_name and db_user:
        DATABASES = {
            'default': dj_database_url.parse(
                f'postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}'
            )
        }
    else:
        DATABASES = {
            'default': {
                'ENGINE': 'django.db.backends.sqlite3',
                'NAME': BASE_DIR / 'db.sqlite3',
            }
        }


# ─── CORS Configuration ─────────────────────────────────────────────────────────
if DEBUG:
    CORS_ALLOW_ALL_ORIGINS = True
else:
    CORS_ALLOWED_ORIGINS = os.environ.get('CORS_ALLOWED_ORIGINS', '').split(',')
    CORS_ALLOW_CREDENTIALS = True

# ─── Email Setup ───────────────────────────────────────────────────────────────
RESEND_API_KEY = os.environ.get('RESEND_API_KEY')

if RESEND_API_KEY:
    EMAIL_BACKEND = 'anymail.backends.resend.EmailBackend'
    ANYMAIL = {
        'RESEND_API_KEY': RESEND_API_KEY,
    }
    DEFAULT_FROM_EMAIL = os.environ.get('DEFAULT_FROM_EMAIL', 'onboarding@resend.dev')
else:
    EMAIL_HOST_USER = os.environ.get('EMAIL_HOST_USER', '')
    EMAIL_HOST_PASSWORD = os.environ.get('EMAIL_HOST_PASSWORD', '')
    if EMAIL_HOST_USER and EMAIL_HOST_PASSWORD:
        EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
        EMAIL_HOST = os.environ.get('EMAIL_HOST', 'smtp.gmail.com')
        EMAIL_PORT = int(os.environ.get('EMAIL_PORT', 587))
        EMAIL_USE_TLS = True
        DEFAULT_FROM_EMAIL = os.environ.get('DEFAULT_FROM_EMAIL', EMAIL_HOST_USER)
    else:
        # Fall back to console backend (prints to console/logs) if neither Resend nor SMTP config is provided
        EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
        DEFAULT_FROM_EMAIL = os.environ.get('DEFAULT_FROM_EMAIL', 'noreply@contact.roomrental.tech')


# ─── Password Validation ───────────────────────────────────────────────────────
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# ─── Internationalization ──────────────────────────────────────────────────────
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

# ─── Static & Media Files ──────────────────────────────────────────────────────
STATIC_URL = 'static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')

# --- Backblaze B2 (S3-compatible) ---
B2_KEY_ID = env("B2_KEY_ID", default=None)
B2_APPLICATION_KEY = env("B2_APPLICATION_KEY", default=None)
B2_BUCKET_NAME = env("B2_BUCKET_NAME", default=None)
B2_ENDPOINT_URL = env("B2_ENDPOINT_URL", default=None)
B2_REGION = env("B2_REGION", default=None)

# Strip trailing slash — boto3 constructs URLs itself and a double-slash causes 400 errors
if B2_ENDPOINT_URL:
    B2_ENDPOINT_URL = B2_ENDPOINT_URL.rstrip("/")

if B2_KEY_ID and B2_APPLICATION_KEY and B2_BUCKET_NAME and B2_ENDPOINT_URL:
    AWS_ACCESS_KEY_ID = B2_KEY_ID
    AWS_SECRET_ACCESS_KEY = B2_APPLICATION_KEY
    AWS_STORAGE_BUCKET_NAME = B2_BUCKET_NAME
    AWS_S3_ENDPOINT_URL = B2_ENDPOINT_URL
    AWS_S3_REGION_NAME = B2_REGION

    AWS_S3_ADDRESSING_STYLE = "path"    # B2 requires path-style addressing
    AWS_S3_FILE_OVERWRITE = False       # don't silently overwrite same-named files
    AWS_QUERYSTRING_AUTH = True          # generates secure, temporary signed URLs
    AWS_QUERYSTRING_EXPIRE = 86400       # default signed URL lifetime: 24 hours
    AWS_S3_SIGNATURE_VERSION = "s3v4"
    AWS_LOCATION = "media"              # all uploads land under media/ in the bucket

    STORAGES = {
        "default": {
            "BACKEND": "storages.backends.s3.S3Storage",
        },
        "staticfiles": {
            "BACKEND": "django.contrib.staticfiles.storage.StaticFilesStorage",
        },
    }

    print(f"[Storage] [B2 ACTIVE] bucket={B2_BUCKET_NAME} endpoint={B2_ENDPOINT_URL}")
else:
    # Local fallback -- only when B2 credentials are missing
    MEDIA_URL = 'media/'
    MEDIA_ROOT = BASE_DIR / 'media'

    print("[Storage] [LOCAL] Disk storage active (media/ folder) -- set B2_* env vars to use Backblaze B2")


# ─── Default Primary Key ───────────────────────────────────────────────────────
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# ─── Django REST Framework ──────────────────────────────────────────────────────
REST_FRAMEWORK = {
    # Use JWT as the default authentication method
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),

    # Default to requiring authentication (override per-view as needed)
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated',
    ),

    # Throttling — rate limits for API abuse prevention
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '100/day',
        'user': '1000/day',
    },

    # Consistent API response format
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
    ],

    # Pagination (can be customized per-view)
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,

    # OpenAPI schema generation
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
}

# In local development, also allow the REST Framework Browsable API
if DEBUG:
    REST_FRAMEWORK['DEFAULT_RENDERER_CLASSES'] = [
        'rest_framework.renderers.JSONRenderer',
        'rest_framework.renderers.BrowsableAPIRenderer',
    ]

# ─── Simple JWT Configuration ──────────────────────────────────────────────────
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=15),   # Short-lived access token
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),      # Longer-lived refresh token
    'ROTATE_REFRESH_TOKENS': True,                    # Issue new refresh on each refresh request
    'BLACKLIST_AFTER_ROTATION': True,                 # Blacklist old refresh token after rotation
    'UPDATE_LAST_LOGIN': True,                        # Update user.last_login on token obtain

    'ALGORITHM': 'HS256',
    'AUTH_HEADER_TYPES': ('Bearer',),
    'AUTH_HEADER_NAME': 'HTTP_AUTHORIZATION',

    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
}

# ─── OTP Configuration ─────────────────────────────────────────────────────────
OTP_EXPIRY_MINUTES = int(os.environ.get('OTP_EXPIRY_MINUTES', 10))

# ─── Maps / OSM Configuration ───────────────────────────────────────────────────
# City name used by osmnx to download the OSM road graph at startup.
# Override via OSM_CITY env var if deploying to a different region.
OSM_CITY = os.environ.get('OSM_CITY', 'Kathmandu, Nepal')

# Payment Gateway Configuration
KHALTI_SECRET_KEY = os.environ.get('KHALTI_SECRET_KEY', '')
KHALTI_API_BASE_URL = os.environ.get('KHALTI_API_BASE_URL', 'https://dev.khalti.com/api/v2')
ESEWA_PRODUCT_CODE = os.environ.get('ESEWA_PRODUCT_CODE', 'EPAYTEST')
ESEWA_API_BASE_URL = os.environ.get('ESEWA_API_BASE_URL', 'https://rc.esewa.com.np')

# Firebase Cloud Messaging
FIREBASE_CREDENTIALS_PATH = os.environ.get('FIREBASE_CREDENTIALS_PATH', '')
if FIREBASE_CREDENTIALS_PATH and not os.path.isabs(FIREBASE_CREDENTIALS_PATH):
    FIREBASE_CREDENTIALS_PATH = os.path.join(BASE_DIR, FIREBASE_CREDENTIALS_PATH)

# ─── OpenAPI Docs (Swagger) ────────────────────────────────────────────────────
SPECTACULAR_SETTINGS = {
    'TITLE': 'Smart Room Renting API',
    'DESCRIPTION': 'REST API Endpoints for Smart Room Renting System',
    'VERSION': '1.0.0',
    'SERVE_INCLUDE_SCHEMA': False,
}

# ─── Caching Setup ─────────────────────────────────────────────────────────────
UPSTASH_REDIS_URL = os.environ.get('UPSTASH_REDIS_URL') or os.environ.get('REDIS_URL')

if UPSTASH_REDIS_URL:
    CACHES = {
        "default": {
            "BACKEND": "django.core.cache.backends.redis.RedisCache",
            "LOCATION": UPSTASH_REDIS_URL,
        }
    }
    print("[Cache] Upstash Redis cache active")
else:
    CACHES = {
        "default": {
            "BACKEND": "django.core.cache.backends.locmem.LocMemCache",
            "LOCATION": "unique-snowflake",
        }
    }
    print("[Cache] Local memory cache active -- set UPSTASH_REDIS_URL to use Upstash Redis")


# ─── Security Hardening (Production Only) ──────────────────────────────────────
if not DEBUG:
    SECURE_BROWSER_XSS_FILTER = True
    SECURE_CONTENT_TYPE_NOSNIFF = True
    SECURE_HSTS_SECONDS = 31536000           # 1 year HSTS
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True
    SECURE_SSL_REDIRECT = True
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
    X_FRAME_OPTIONS = 'DENY'
