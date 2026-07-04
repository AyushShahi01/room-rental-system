import random
from django.core.management.base import BaseCommand
from rooms.models import Room

# Kathmandu's approximate geographic bounding box (to align with OSM graph)
NEPAL_LAT_MIN = 27.670
NEPAL_LAT_MAX = 27.730
NEPAL_LON_MIN = 85.280
NEPAL_LON_MAX = 85.350



class Command(BaseCommand):
    help = 'Assign random Nepal coordinates to rooms that have no latitude/longitude set.'

    def add_arguments(self, parser):
        parser.add_argument(
            '--all',
            action='store_true',
            help='Overwrite coordinates even for rooms that already have lat/lng set.',
        )

    def handle(self, *args, **options):
        overwrite = options['all']

        if overwrite:
            rooms = list(Room.objects.all())
            self.stdout.write('Mode: overwriting ALL rooms (including those with existing coordinates).')
        else:
            rooms = list(Room.objects.filter(latitude__isnull=True) | Room.objects.filter(longitude__isnull=True))
            self.stdout.write('Mode: filling only rooms with missing coordinates.')

        total = len(rooms)
        if total == 0:
            self.stdout.write(self.style.WARNING('No rooms to update.'))
            return

        for room in rooms:
            room.latitude = round(random.uniform(NEPAL_LAT_MIN, NEPAL_LAT_MAX), 6)
            room.longitude = round(random.uniform(NEPAL_LON_MIN, NEPAL_LON_MAX), 6)

        Room.objects.bulk_update(rooms, ['latitude', 'longitude'])

        self.stdout.write(
            self.style.SUCCESS(
                f'Successfully updated {total} room(s) with random Nepal coordinates.'
            )
        )
