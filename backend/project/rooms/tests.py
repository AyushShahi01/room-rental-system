from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from users.models import CustomUser
from .models import Room

class RoomTests(APITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(username='landlord', password='password', is_landlord=True)
        self.room_list_url = reverse('room-list-create')
        self.room_data = {
            'landlord': self.user.id,
            'title': 'Nice Room',
            'description': 'A very nice room',
            'price': '500.00',
            'is_available': True
        }

    def test_create_room(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.post(self.room_list_url, self.room_data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
