from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from bookings.models import Booking
from rooms.models import Room
from users.models import CustomUser
from .models import Message


class MessagingTests(APITestCase):
    def setUp(self):
        self.tenant = CustomUser.objects.create_user(username='tenant', password='password', role='tenant')
        self.landlord = CustomUser.objects.create_user(username='landlord', password='password', role='landlord')
        self.other = CustomUser.objects.create_user(username='other', password='password', role='tenant')
        self.room = Room.objects.create(
            landlord=self.landlord,
            title='Room',
            description='Desc',
            price='100.00',
            province='Bagmati',
            state='Kathmandu',
            ward_number=7,
        )
        self.booking = Booking.objects.create(tenant=self.tenant, room=self.room, status=Booking.STATUS_APPROVED)

    def test_send_message_creates_notification(self):
        self.client.force_authenticate(user=self.tenant)
        response = self.client.post(reverse('message-list-create'), {
            'receiver': self.landlord.id,
            'content': 'Hello',
            'booking_id': self.booking.id,
        })

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(self.landlord.notification_set.count(), 1)

    def test_recipient_filter_returns_thread(self):
        Message.objects.create(sender=self.tenant, receiver=self.landlord, content='A')
        Message.objects.create(sender=self.landlord, receiver=self.tenant, content='B')
        Message.objects.create(sender=self.tenant, receiver=self.other, content='C')

        self.client.force_authenticate(user=self.tenant)
        response = self.client.get(reverse('message-list-create'), {'recipient_id': self.landlord.id})

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 2)

    def test_conversation_list_returns_unique_partners(self):
        Message.objects.create(sender=self.tenant, receiver=self.landlord, content='A')
        Message.objects.create(sender=self.landlord, receiver=self.tenant, content='B')
        Message.objects.create(sender=self.tenant, receiver=self.other, content='C')

        self.client.force_authenticate(user=self.tenant)
        response = self.client.get(reverse('message-conversations'))

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 2)

    def test_receiver_can_mark_message_read(self):
        message = Message.objects.create(sender=self.tenant, receiver=self.landlord, content='A')
        self.client.force_authenticate(user=self.landlord)
        response = self.client.patch(reverse('mark-message-read', kwargs={'pk': message.pk}))

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        message.refresh_from_db()
        self.assertTrue(message.is_read)
