from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from users.models import CustomUser
from rooms.models import Room
from bookings.models import Booking
from .models import Payment

class PaymentTests(APITestCase):
    def setUp(self):
        self.tenant = CustomUser.objects.create_user(username='tenant', password='password')
        self.landlord = CustomUser.objects.create_user(username='landlord', password='password')
        self.room = Room.objects.create(landlord=self.landlord, title='Room', description='Desc', price='100.00')
        self.booking = Booking.objects.create(tenant=self.tenant, room=self.room)
        self.payment_url = reverse('payment-list-create')

    def test_create_payment(self):
        self.client.force_authenticate(user=self.tenant)
        data = {'booking': self.booking.id, 'amount': '100.00', 'status': 'pending'}
        response = self.client.post(self.payment_url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
