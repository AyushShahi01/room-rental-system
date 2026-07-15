import os
import sys
import django

# Set up Django environment
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'project.settings')
django.setup()

from django.core.mail import send_mail
from django.conf import settings

print("Selected EMAIL_BACKEND:", settings.EMAIL_BACKEND)
print("DEFAULT_FROM_EMAIL:", settings.DEFAULT_FROM_EMAIL)
if hasattr(settings, 'ANYMAIL'):
    print("ANYMAIL config:", {k: '***' if 'key' in k.lower() else v for k, v in settings.ANYMAIL.items()})

try:
    send_mail(
        'Test Subject',
        'Test message body.',
        settings.DEFAULT_FROM_EMAIL,
        ['ayush.shahi.147@gmail.com'], # Trying to send to the user's email
        fail_silently=False,
    )
    print("Email sent successfully!")
except Exception as e:
    import traceback
    print("Email sending failed with exception:")
    traceback.print_exc()
