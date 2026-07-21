import django
from django.shortcuts import render
from django.utils import timezone
from django.conf import settings

def home_view(request):
    """
    Render the root landing page & API dashboard.
    """
    context = {
        "django_version": django.get_version(),
        "debug_mode": settings.DEBUG,
        "server_time": timezone.now().strftime("%Y-%m-%d %H:%M:%S UTC"),
        "modules": [
            {
                "name": "Authentication & Users",
                "prefix": "/api/auth/",
                "icon": "user-check",
                "description": "User registration, login, JWT token refresh, profile management, and roles (Landlord/Tenant)."
            },
            {
                "name": "Rooms & Properties",
                "prefix": "/api/rooms/",
                "icon": "home",
                "description": "Property listings, room details, availability status, amenities, and search filters."
            },
            {
                "name": "Bookings & Requests",
                "prefix": "/api/bookings/",
                "icon": "calendar",
                "description": "Room booking requests, approval workflow, check-in schedules, and status tracking."
            },
            {
                "name": "Rent & Payments",
                "prefix": "/api/rent/",
                "icon": "credit-card",
                "description": "Rental billing, payment collection, transaction history, and payment gateway integration."
            },
            {
                "name": "Rental Agreements",
                "prefix": "/api/agreements/",
                "icon": "file-text",
                "description": "Digital lease agreement generation, terms verification, and digital signatures."
            },
            {
                "name": "Maintenance Requests",
                "prefix": "/api/maintenance/",
                "icon": "wrench",
                "description": "Issue reporting, maintenance ticket assignment, resolution updates, and asset management."
            },
            {
                "name": "In-App Messaging",
                "prefix": "/api/messages/",
                "icon": "message-square",
                "description": "Real-time tenant-landlord communication, chat threads, and message history."
            },
            {
                "name": "Notifications",
                "prefix": "/api/notifications/",
                "icon": "bell",
                "description": "Push & in-app alerts for payment reminders, booking updates, and system notices."
            },
            {
                "name": "Maps & Location",
                "prefix": "/api/maps/",
                "icon": "map-pin",
                "description": "Geocoding, interactive property maps, and location proximity search."
            },
        ],
        "quick_links": [
            {
                "title": "Swagger UI",
                "url": "/api/docs/swagger/",
                "badge": "Interactive",
                "badge_class": "badge-primary",
                "icon": "play-circle",
                "description": "Explore and execute REST API requests directly from your browser."
            },
            {
                "title": "ReDoc Documentation",
                "url": "/api/docs/redoc/",
                "badge": "Reference",
                "badge_class": "badge-info",
                "icon": "book-open",
                "description": "Comprehensive, clean API specification and data model schema."
            },
            {
                "title": "SuperAdmin Portal",
                "url": "/superadmin/",
                "badge": "Management",
                "badge_class": "badge-warning",
                "icon": "shield",
                "description": "Django administrative portal for data management & system configuration."
            },
            {
                "title": "OpenAPI JSON Schema",
                "url": "/api/schema/",
                "badge": "Raw Spec",
                "badge_class": "badge-secondary",
                "icon": "code",
                "description": "Download or consume OpenAPI 3.0 specification JSON schema."
            },
        ]
    }
    return render(request, "index.html", context)
