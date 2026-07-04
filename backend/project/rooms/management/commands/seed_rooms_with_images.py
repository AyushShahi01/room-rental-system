import random
from decimal import Decimal
from io import BytesIO
from PIL import Image, ImageDraw
from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from django.core.management.base import BaseCommand
from django.db import transaction

from rooms.models import Room, RoomImage

# Kathmandu bounds for graph compatibility
LAT_MIN, LAT_MAX = 27.670, 27.730
LON_MIN, LON_MAX = 85.280, 85.350

COZY_COLORS = [
    (212, 163, 115),  # Cozy Warm (Orange-brown)
    (204, 213, 174),  # Modern Sage (Green)
    (168, 218, 220),  # Ocean Breeze (Teal)
    (69, 123, 157),   # Indigo Sky (Blue)
    (230, 57, 70),    # Crimson Dusk (Red)
]

ROOM_TITLES = [
    "Cozy Studio near Thamel",
    "Modern Apartment in Baneshwor",
    "Traditional Patan Courtyard Room",
    "Spacious Bedroom in Maharajgunj",
    "Sunlit Studio Apartment, Lazimpat",
    "Budget Friendly Room near Kirtipur",
    "Premium Penthouse Room, Jhamsikhel",
    "Cozy Shared Apartment, Baluwatar",
    "Elegant Suite near Kathmandu Durbar Square",
    "Comfortable Single Room, Kalimati",
    "Charming Attic Room in Lalitpur",
    "Quiet Residential Room, Koteshwor",
    "Modern Loft Room, Chabahil",
    "Chic Studio Apartment, Gongabu",
    "Peaceful Room near Swayambhu",
]

DESCRIPTIONS = [
    "A clean, well-lit space perfect for students and working professionals. Located in a quiet neighborhood with easy access to public transport.",
    "Fully renovated room offering modern aesthetics and standard amenities. Close to local eateries, shopping centers, and banks.",
    "Experience traditional Kathmandu living with this beautifully designed room. Features wooden windows, cozy seating, and safe parking.",
    "Spacious, airy bedroom with a private attached bathroom. Includes high-speed internet connectivity and shared kitchen access.",
    "A beautiful sunlit studio with modern interior design, proper ventilation, and continuous water supply. Ideal for couples or solo travelers.",
]


def generate_room_image(title: str, index: int) -> SimpleUploadedFile:
    # Generate a nice graphic image
    img = Image.new('RGB', (800, 500), color=COZY_COLORS[index % len(COZY_COLORS)])
    draw = ImageDraw.Draw(img)
    
    # Draw simple design shapes (cozy house graphic)
    draw.rectangle([50, 50, 750, 450], outline=(255, 255, 255), width=3)
    draw.polygon([(400, 100), (200, 250), (600, 250)], fill=(255, 255, 255, 128))
    draw.rectangle([250, 250, 550, 400], fill=(255, 255, 255, 128))
    draw.rectangle([360, 300, 440, 400], fill=(60, 60, 60))
    
    # Write room title
    draw.text((80, 410), f"Premium Listing: {title}", fill=(255, 255, 255))

    img_io = BytesIO()
    img.save(img_io, format='JPEG', quality=85)
    img_io.seek(0)
    
    return SimpleUploadedFile(
        name=f"seeded_room_{index}.jpg",
        content=img_io.read(),
        content_type="image/jpeg"
    )


class Command(BaseCommand):
    help = "Seed 15 Kathmandu rooms with 5 landlords, complete with accurate details and mock room images."

    def add_arguments(self, parser):
        parser.add_argument(
            "--recreate",
            action="store_true",
            help="Delete all previously seeded 'dev_prefix' rooms and landlords first.",
        )

    @transaction.atomic
    def handle(self, *args, **options):
        recreate = options["recreate"]
        User = get_user_model()
        prefix = "dev"

        if recreate:
            self.stdout.write("Deleting old seeded data...")
            Room.objects.filter(title__in=ROOM_TITLES).delete()
            Room.objects.filter(title__startswith=f"{prefix}_room_").delete()
            User.objects.filter(username__startswith=f"{prefix}_landlord_").delete()

        # ── 1. Create 5 Landlords ─────────────────────────────────────────────
        landlords = []
        password = "Landlord@12345"
        for i in range(1, 6):
            username = f"{prefix}_landlord_{i}"
            email = f"{username}@example.com"
            landlord, created = User.objects.get_or_create(
                username=username,
                defaults={
                    "email": email,
                    "first_name": f"Landlord {i}",
                    "last_name": "Seeded",
                    "role": "landlord",
                    "province": "Bagmati",
                    "district": "Kathmandu",
                    "city": "Kathmandu",
                    "ward": i,
                }
            )
            if created:
                landlord.set_password(password)
                landlord.save()
            landlords.append(landlord)

        self.stdout.write(self.style.SUCCESS(f"Successfully ensured 5 landlords."))

        # ── 2. Create 15 Rooms (3 per Landlord) ────────────────────────────────
        rooms_created = 0
        for index, title in enumerate(ROOM_TITLES):
            landlord = landlords[index % len(landlords)]
            
            # Place room in Kathmandu bounds (so Dijkstra routing always resolves)
            lat = round(random.uniform(LAT_MIN, LAT_MAX), 6)
            lng = round(random.uniform(LON_MIN, LON_MAX), 6)
            
            price = Decimal(random.randint(8, 25) * 1000)  # 8k to 25k NPR
            sec_deposit = price * Decimal(1.5)  # 1.5 months deposit
            maintenance = Decimal(random.randint(5, 15) * 100)  # 500 to 1500 NPR
            area = random.randint(120, 350)  # 120 to 350 sqft
            
            room, created = Room.objects.get_or_create(
                landlord=landlord,
                title=title,
                defaults={
                    "description": random.choice(DESCRIPTIONS),
                    "price": price,
                    "province": "Bagmati",
                    "state": "Kathmandu",
                    "ward_number": random.randint(1, 32),
                    "furnished_status": index % 2 == 0,
                    "area_sqft": area,
                    "security_deposit": sec_deposit,
                    "maintenance_charges": maintenance,
                    "has_wifi": index % 3 != 0,
                    "has_ac": index % 5 == 0,
                    "has_attached_bathroom": index % 2 == 1,
                    "parking_available": index % 3 == 0,
                    "food_available": index % 4 == 0,
                    "gender_preference": ["any", "male", "female"][index % 3],
                    "water_supply_available": True,
                    "waste_collection_available": True,
                    "is_available": True,
                    "latitude": lat,
                    "longitude": lng,
                }
            )
            
            if created:
                rooms_created += 1
                # ── 3. Generate and Attach a Premium Room Image ───────────────
                image_file = generate_room_image(title, index)
                RoomImage.objects.create(
                    room=room,
                    image=image_file
                )
                
        self.stdout.write(
            self.style.SUCCESS(
                f"Successfully seeded {rooms_created} rooms with custom Kathmandu coordinates and room images!"
            )
        )
