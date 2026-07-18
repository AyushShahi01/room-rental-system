from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from users.models import CustomUser
from .models import Room

class RoomTests(APITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(username='landlord', password='password', role='landlord')
        self.room_list_url = reverse('room-list-create')
        self.room_data = {
            'landlord': self.user.id,
            'title': 'Nice Room',
            'description': 'A very nice room',
            'price': '500.00',
            'province': 'Bagmati',
            'state': 'Kathmandu',
            'ward_number': 7,
            'is_available': True
        }

    def test_list_rooms_without_auth(self):
        Room.objects.create(
            landlord=self.user,
            title='Public Room',
            description='Available to everyone',
            price='500.00',
            province='Bagmati',
            state='Kathmandu',
            ward_number=7,
            is_available=True,
        )
        response = self.client.get(self.room_list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 1)

    def test_create_room(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.post(self.room_list_url, self.room_data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_room_image_upload(self):
        from django.core.files.uploadedfile import SimpleUploadedFile
        self.client.force_authenticate(user=self.user)
        room = Room.objects.create(
            landlord=self.user,
            title='Room for Image test',
            description='A room',
            price='500.00',
            province='Bagmati',
            state='Kathmandu',
            ward_number=7,
            is_available=True
        )
        url = reverse('room-image-upload', kwargs={'room_id': room.id})

        gif_bytes = (
            b'\x47\x49\x46\x38\x39\x61\x01\x00\x01\x00\x80\x00\x00\x00\x00\x00'
            b'\xff\xff\xff\x21\xf9\x04\x01\x00\x00\x00\x00\x2c\x00\x00\x00\x00'
            b'\x01\x00\x01\x00\x00\x02\x02\x44\x01\x00\x3b'
        )
        room_image = SimpleUploadedFile('room.gif', gif_bytes, content_type='image/gif')

        response = self.client.post(url, {'images': [room_image]}, format='multipart')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIsInstance(response.data, list)
        self.assertEqual(len(response.data), 1)
        self.assertIsNotNone(response.data[0]['image'])


    def test_city_filter_aliases_state(self):
        Room.objects.create(
            landlord=self.user,
            title='Kathmandu Room',
            description='Desc',
            price='500.00',
            province='Bagmati',
            state='Kathmandu',
            ward_number=7,
            is_available=True,
        )
        Room.objects.create(
            landlord=self.user,
            title='Pokhara Room',
            description='Desc',
            price='500.00',
            province='Gandaki',
            state='Pokhara',
            ward_number=4,
            is_available=True,
        )

        response = self.client.get(self.room_list_url, {'city': 'Kathmandu'})

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        titles = {item['title'] for item in response.data['results']}
        self.assertEqual(titles, {'Kathmandu Room'})


class RoomRecommendationTests(APITestCase):
    def setUp(self):
        self.landlord = CustomUser.objects.create_user(username='landlord2', password='password', role='landlord')
        self.recommendations_url = reverse('recommended-rooms')

        self.best_room = Room.objects.create(
            landlord=self.landlord,
            title='Best Match',
            description='Same location and features',
            price='500.00',
            province='Bagmati',
            state='Kathmandu',
            ward_number=7,
            furnished_status=True,
            has_wifi=True,
            has_ac=True,
            has_attached_bathroom=True,
            parking_available=True,
            food_available=True,
            water_supply_available=True,
            waste_collection_available=True,
            gender_preference='male',
            is_available=True,
        )

        self.second_room = Room.objects.create(
            landlord=self.landlord,
            title='Partial Match',
            description='Different location and fewer features',
            price='850.00',
            province='Gandaki',
            state='Pokhara',
            ward_number=4,
            furnished_status=False,
            has_wifi=False,
            has_ac=False,
            has_attached_bathroom=False,
            parking_available=False,
            food_available=False,
            water_supply_available=False,
            waste_collection_available=False,
            gender_preference='any',
            is_available=True,
        )

        Room.objects.create(
            landlord=self.landlord,
            title='Unavailable Room',
            description='Should not appear in recommendations',
            price='500.00',
            province='Bagmati',
            state='Kathmandu',
            ward_number=9,
            furnished_status=True,
            has_wifi=True,
            has_ac=True,
            has_attached_bathroom=True,
            parking_available=True,
            food_available=True,
            water_supply_available=True,
            waste_collection_available=True,
            gender_preference='male',
            is_available=False,
        )

    def test_recommendations_rank_best_match_first(self):
        payload = {
            'preferred_price': '500.00',
            'province': 'Bagmati',
            'state': 'Kathmandu',
            'furnished_status': True,
            'has_wifi': True,
            'has_ac': True,
            'has_attached_bathroom': True,
            'parking_available': True,
            'food_available': True,
            'water_supply_available': True,
            'waste_collection_available': True,
            'gender_preference': 'male',
            'limit': 5,
        }

        response = self.client.post(self.recommendations_url, payload, format='json')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 2)
        self.assertEqual(response.data['results'][0]['room']['id'], self.best_room.id)
        self.assertGreater(response.data['results'][0]['combined_score'], response.data['results'][1]['combined_score'])
        self.assertEqual(response.data['results'][0]['location_score'], 1.0)
        self.assertEqual(response.data['results'][0]['combined_score'], 1.0)

    def test_recommendations_with_coordinates(self):
        # Set coordinates on rooms (Kathmandu vs Pokhara)
        self.best_room.latitude = 27.7172
        self.best_room.longitude = 85.3240
        self.best_room.save()

        self.second_room.latitude = 28.2096
        self.second_room.longitude = 83.9856
        self.second_room.save()

        payload = {
            'preferred_price': '500.00',
            'latitude': 27.7172,
            'longitude': 85.3240,
            'furnished_status': True,
            'has_wifi': True,
            'limit': 5,
        }

        response = self.client.post(self.recommendations_url, payload, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 2)

        results = {item['room']['id']: item for item in response.data['results']}
        best_match_result = results[self.best_room.id]
        second_match_result = results[self.second_room.id]

        # best_room is exactly at the coordinates -> location_score should be 1.0
        self.assertEqual(best_match_result['location_score'], 1.0)
        # second_room is in Pokhara (~140km away) -> location_score should decay to 0.0
        self.assertEqual(second_match_result['location_score'], 0.0)

    def test_recommendations_price_directional_penalty_and_gender_hard_filter(self):
        # Create a cheaper room (budget $500, room price $300) -> should have price_score = 1.0 (no penalty)
        cheaper_room = Room.objects.create(
            landlord=self.landlord,
            title='Cheaper Room',
            description='Below budget',
            price='300.00',
            province='Bagmati',
            state='Kathmandu',
            ward_number=7,
            gender_preference='any',
            is_available=True,
        )

        # Create a female-only room -> should be hard-excluded because the payload has gender_preference='male'
        female_room = Room.objects.create(
            landlord=self.landlord,
            title='Female Only Room',
            description='Female only',
            price='500.00',
            province='Bagmati',
            state='Kathmandu',
            ward_number=7,
            gender_preference='female',
            is_available=True,
        )

        payload = {
            'preferred_price': '500.00',
            'province': 'Bagmati',
            'state': 'Kathmandu',
            'gender_preference': 'male',
            'limit': 10,
        }

        response = self.client.post(self.recommendations_url, payload, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        # Female room must be hard-excluded. best_room, second_room, and cheaper_room should remain.
        # So we expect 3 rooms
        self.assertEqual(response.data['count'], 3)

        returned_ids = [item['room']['id'] for item in response.data['results']]
        self.assertNotIn(female_room.id, returned_ids)
        self.assertIn(cheaper_room.id, returned_ids)

        # Let's verify cheaper_room is ranked higher or equal than an over-budget room
        # self.second_room has price 850.00 (over budget 500.00)
        results = {item['room']['id']: item for item in response.data['results']}
        self.assertGreater(results[cheaper_room.id]['combined_score'], results[self.second_room.id]['combined_score'])


