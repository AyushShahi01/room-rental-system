from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from users.models import CustomUser
from rooms.models import Room
from .models import Booking


class BookingTests(APITestCase):
    def setUp(self):
        self.landlord = CustomUser.objects.create_user(
            username='landlord', password='password', role='landlord'
        )
        self.tenant = CustomUser.objects.create_user(
            username='tenant', password='password', role='tenant'
        )
        self.room = Room.objects.create(
            landlord=self.landlord,
            title='Room',
            description='Desc',
            price='100.00',
            province='Bagmati',
            state='Kathmandu',
            ward_number=7,
        )
        self.booking_url = reverse('booking-list-create')

    def test_create_booking(self):
        self.client.force_authenticate(user=self.tenant)
        data = {'room': self.room.id}
        response = self.client.post(self.booking_url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['status'], 'pending')

    def test_create_booking_has_created_at(self):
        self.client.force_authenticate(user=self.tenant)
        data = {'room': self.room.id}
        response = self.client.post(self.booking_url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('created_at', response.data)
        self.assertIsNotNone(response.data['created_at'])

    def test_approve_booking_flips_room_availability(self):
        """When a booking is approved, the room should become unavailable."""
        booking = Booking.objects.create(
            tenant=self.tenant, room=self.room, status=Booking.STATUS_PENDING
        )
        self.client.force_authenticate(user=self.landlord)
        url = reverse('booking-approve', kwargs={'pk': booking.pk})
        response = self.client.patch(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        booking.refresh_from_db()
        self.assertEqual(booking.status, Booking.STATUS_APPROVED)

        self.room.refresh_from_db()
        self.assertFalse(self.room.is_available)

    def test_cancel_approved_booking_frees_room(self):
        """Cancelling an approved booking should make the room available again."""
        booking = Booking.objects.create(
            tenant=self.tenant, room=self.room, status=Booking.STATUS_APPROVED
        )
        self.room.is_available = False
        self.room.save(update_fields=['is_available'])

        self.client.force_authenticate(user=self.tenant)
        url = reverse('booking-cancel', kwargs={'pk': booking.pk})
        response = self.client.patch(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        booking.refresh_from_db()
        self.assertEqual(booking.status, Booking.STATUS_CANCELLED)

        self.room.refresh_from_db()
        self.assertTrue(self.room.is_available)

    def test_cancel_pending_booking_does_not_change_room(self):
        """Cancelling a pending booking should not touch room availability."""
        booking = Booking.objects.create(
            tenant=self.tenant, room=self.room, status=Booking.STATUS_PENDING
        )
        self.assertTrue(self.room.is_available)

        self.client.force_authenticate(user=self.tenant)
        url = reverse('booking-cancel', kwargs={'pk': booking.pk})
        response = self.client.patch(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.room.refresh_from_db()
        self.assertTrue(self.room.is_available)

    def test_reject_booking_does_not_change_room(self):
        """Rejecting a pending booking should not change room availability."""
        booking = Booking.objects.create(
            tenant=self.tenant, room=self.room, status=Booking.STATUS_PENDING
        )
        self.client.force_authenticate(user=self.landlord)
        url = reverse('booking-reject', kwargs={'pk': booking.pk})
        response = self.client.patch(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.room.refresh_from_db()
        self.assertTrue(self.room.is_available)

    def test_cannot_approve_non_pending_booking(self):
        """Approving an already-approved booking should fail."""
        booking = Booking.objects.create(
            tenant=self.tenant, room=self.room, status=Booking.STATUS_APPROVED
        )
        self.client.force_authenticate(user=self.landlord)
        url = reverse('booking-approve', kwargs={'pk': booking.pk})
        response = self.client.patch(url)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_cannot_reject_non_pending_booking(self):
        """Rejecting an already-rejected booking should fail."""
        booking = Booking.objects.create(
            tenant=self.tenant, room=self.room, status=Booking.STATUS_REJECTED
        )
        self.client.force_authenticate(user=self.landlord)
        url = reverse('booking-reject', kwargs={'pk': booking.pk})
        response = self.client.patch(url)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
