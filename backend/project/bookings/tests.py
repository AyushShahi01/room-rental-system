from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from users.models import CustomUser
from rooms.models import Room
from .models import Booking

class BookingTests(APITestCase):
    def setUp(self):
        self.landlord = CustomUser.objects.create_user(username='landlord', password='password')
        self.tenant = CustomUser.objects.create_user(username='tenant', password='password')
        self.room = Room.objects.create(landlord=self.landlord, title='Room', description='Desc', price='100.00')
        self.booking_url = reverse('booking-list-create')

    def test_create_booking(self):
        self.client.force_authenticate(user=self.tenant)
        data = {'tenant': self.tenant.id, 'room': self.room.id, 'status': 'pending'}
        response = self.client.post(self.booking_url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
