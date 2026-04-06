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

    def test_create_room(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.post(self.room_list_url, self.room_data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)


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
            gender_preference='female',
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

