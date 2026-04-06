from decimal import Decimal

from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand
from django.db import transaction

from rooms.models import Room


LOCATION_PAIRS = [
    ("Bagmati", "Kathmandu"),
    ("Bagmati", "Bhaktapur"),
    ("Bagmati", "Lalitpur"),
    ("Gandaki", "Pokhara"),
    ("Koshi", "Dharan"),
    ("Lumbini", "Butwal"),
]


class Command(BaseCommand):
    help = "Seed dummy landlord accounts and rooms for recommendation testing."

    def add_arguments(self, parser):
        parser.add_argument(
            "--landlords",
            type=int,
            default=5,
            help="Number of landlord accounts to seed (default: 5).",
        )
        parser.add_argument(
            "--rooms-per-landlord",
            type=int,
            default=8,
            help="Number of rooms to seed per landlord (default: 8).",
        )
        parser.add_argument(
            "--password",
            type=str,
            default="Landlord@12345",
            help="Password assigned to newly created seed landlords.",
        )
        parser.add_argument(
            "--prefix",
            type=str,
            default="seed",
            help="Prefix used for seeded usernames and room titles (default: seed).",
        )
        parser.add_argument(
            "--recreate",
            action="store_true",
            help="Delete existing prefixed seeded rooms and landlords before seeding.",
        )

    @transaction.atomic
    def handle(self, *args, **options):
        landlord_count = options["landlords"]
        rooms_per_landlord = options["rooms_per_landlord"]
        password = options["password"]
        prefix = options["prefix"].strip(" _-") or "seed"
        recreate = options["recreate"]

        if landlord_count <= 0:
            self.stderr.write(self.style.ERROR("--landlords must be greater than 0."))
            return
        if rooms_per_landlord <= 0:
            self.stderr.write(self.style.ERROR("--rooms-per-landlord must be greater than 0."))
            return

        User = get_user_model()

        deleted_rooms = 0
        deleted_landlords = 0
        if recreate:
            deleted_rooms, _ = Room.objects.filter(title__startswith=f"{prefix}_room_").delete()
            deleted_landlords, _ = User.objects.filter(username__startswith=f"{prefix}_landlord_").delete()

        landlords_created = 0
        landlords_reused = 0
        rooms_created = 0
        rooms_reused = 0

        for landlord_index in range(1, landlord_count + 1):
            username = f"{prefix}_landlord_{landlord_index}"
            email = f"{username}@example.com"

            landlord, created = User.objects.get_or_create(
                username=username,
                defaults={
                    "email": email,
                    "first_name": f"Seed{landlord_index}",
                    "last_name": "Landlord",
                    "role": "landlord",
                    "province": LOCATION_PAIRS[(landlord_index - 1) % len(LOCATION_PAIRS)][0],
                    "district": LOCATION_PAIRS[(landlord_index - 1) % len(LOCATION_PAIRS)][1],
                    "city": LOCATION_PAIRS[(landlord_index - 1) % len(LOCATION_PAIRS)][1],
                    "ward": ((landlord_index - 1) % 9) + 1,
                },
            )

            if created:
                landlord.set_password(password)
                landlord.save(update_fields=["password"])
                landlords_created += 1
            else:
                updates = []
                if getattr(landlord, "role", None) != "landlord":
                    landlord.role = "landlord"
                    updates.append("role")
                if not landlord.email:
                    landlord.email = email
                    updates.append("email")
                if updates:
                    landlord.save(update_fields=updates)
                landlords_reused += 1

            for room_offset in range(rooms_per_landlord):
                room_index = ((landlord_index - 1) * rooms_per_landlord) + room_offset + 1
                province, state = LOCATION_PAIRS[(room_index - 1) % len(LOCATION_PAIRS)]
                ward_number = ((room_index - 1) % 18) + 1

                title = f"{prefix}_room_{landlord_index}_{room_offset + 1}"
                description = (
                    f"Auto-seeded room #{room_index} in {state}, {province} "
                    "for recommendation testing."
                )

                amenities_seed = room_index
                defaults = {
                    "description": description,
                    "price": Decimal(350 + ((room_index * 90) % 1700)),
                    "province": province,
                    "state": state,
                    "ward_number": ward_number,
                    "furnished_status": amenities_seed % 2 == 0,
                    "area_sqft": 90 + ((room_index * 25) % 310),
                    "security_deposit": Decimal(500 + ((room_index * 75) % 3000)),
                    "maintenance_charges": Decimal(100 + ((room_index * 15) % 600)),
                    "has_wifi": amenities_seed % 2 == 1,
                    "has_ac": amenities_seed % 3 == 0,
                    "has_attached_bathroom": amenities_seed % 4 != 0,
                    "parking_available": amenities_seed % 5 == 0,
                    "food_available": amenities_seed % 3 == 1,
                    "gender_preference": ["any", "male", "female"][amenities_seed % 3],
                    "water_supply_available": amenities_seed % 2 == 0,
                    "waste_collection_available": amenities_seed % 2 == 1,
                    "is_available": True,
                }

                room, room_created = Room.objects.get_or_create(
                    landlord=landlord,
                    title=title,
                    defaults=defaults,
                )

                if room_created:
                    rooms_created += 1
                else:
                    dirty_fields = []
                    for field_name, new_value in defaults.items():
                        current_value = getattr(room, field_name)
                        if current_value != new_value:
                            setattr(room, field_name, new_value)
                            dirty_fields.append(field_name)
                    if dirty_fields:
                        room.save(update_fields=dirty_fields)
                    rooms_reused += 1

        self.stdout.write(self.style.SUCCESS("Seeding completed."))
        self.stdout.write(
            f"Landlords -> created: {landlords_created}, reused: {landlords_reused}, deleted: {deleted_landlords}"
        )
        self.stdout.write(
            f"Rooms -> created: {rooms_created}, reused: {rooms_reused}, deleted: {deleted_rooms}"
        )
