from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from bookings.models import Booking
from rooms.models import Room
from users.models import CustomUser
from .models import Agreement


class AgreementTests(APITestCase):
    def setUp(self):
        self.landlord = CustomUser.objects.create_user(username='landlord', password='password', role='landlord')
        self.other_landlord = CustomUser.objects.create_user(username='other-landlord', password='password', role='landlord')
        self.tenant = CustomUser.objects.create_user(username='tenant', password='password', role='tenant')
        self.room = Room.objects.create(
            landlord=self.landlord,
            title='Room',
            description='Desc',
            price='100.00',
            province='Bagmati',
            state='Kathmandu',
            ward_number=7,
            security_deposit='500.00',
            maintenance_charges='50.00',
        )
        self.booking = Booking.objects.create(tenant=self.tenant, room=self.room, status=Booking.STATUS_APPROVED)

    def test_landlord_can_create_auto_generated_agreement(self):
        self.client.force_authenticate(user=self.landlord)
        response = self.client.post(reverse('agreement-list-create'), {'booking': self.booking.id})

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('Lease Agreement', response.data['content'])
        self.assertIn(self.room.title, response.data['content'])

    def test_tenant_cannot_create_agreement(self):
        self.client.force_authenticate(user=self.tenant)
        response = self.client.post(reverse('agreement-list-create'), {'booking': self.booking.id})

        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_other_landlord_cannot_create_agreement(self):
        self.client.force_authenticate(user=self.other_landlord)
        response = self.client.post(reverse('agreement-list-create'), {'booking': self.booking.id})

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_tenant_can_sign_agreement_once(self):
        agreement = Agreement.objects.create(booking=self.booking, content='Terms')
        self.client.force_authenticate(user=self.tenant)
        url = reverse('sign-agreement', kwargs={'pk': agreement.pk})

        response = self.client.patch(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        agreement.refresh_from_db()
        self.assertTrue(agreement.is_signed)
        self.assertIsNotNone(agreement.signed_at)

        second_response = self.client.patch(url)
        self.assertEqual(second_response.status_code, status.HTTP_200_OK)
        self.assertEqual(second_response.data['message'], 'Agreement already signed.')
