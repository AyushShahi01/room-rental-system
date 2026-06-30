from django.core.files.uploadedfile import SimpleUploadedFile
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from rooms.models import Room
from users.models import CustomUser
from .models import MaintenanceRequest


class MaintenanceTests(APITestCase):
    def setUp(self):
        self.tenant = CustomUser.objects.create_user(username='tenant', password='password', role='tenant')
        self.landlord = CustomUser.objects.create_user(username='landlord', password='password', role='landlord')
        self.room = Room.objects.create(
            landlord=self.landlord,
            title='Room',
            description='Desc',
            price='100.00',
            province='Bagmati',
            state='Kathmandu',
            ward_number=7,
        )

    def test_create_maintenance_with_image(self):
        self.client.force_authenticate(user=self.tenant)
        gif_bytes = b'\x47\x49\x46\x38\x39\x61\x01\x00\x01\x00\x00\x00\x00\x21\xf9\x04\x01\x0a\x00\x01\x00\x2c\x00\x00\x00\x00\x01\x00\x01\x00\x00\x02\x02\x4c\x01\x00\x3b'
        image = SimpleUploadedFile('issue.gif', gif_bytes, content_type='image/gif')
        response = self.client.post(reverse('maintenance-list-create'), {
            'room': self.room.id,
            'description': 'Leaking tap',
            'image': image,
        }, format='multipart')

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('image', response.data)
        self.assertEqual(self.landlord.notification_set.count(), 1)

    def test_landlord_updates_status_and_notifies_tenant(self):
        maintenance = MaintenanceRequest.objects.create(
            tenant=self.tenant,
            room=self.room,
            description='Leaking tap',
        )
        self.client.force_authenticate(user=self.landlord)
        response = self.client.patch(reverse('maintenance-status', kwargs={'pk': maintenance.pk}), {
            'status': MaintenanceRequest.STATUS_IN_PROGRESS,
        })

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        maintenance.refresh_from_db()
        self.assertEqual(maintenance.status, MaintenanceRequest.STATUS_IN_PROGRESS)
        self.assertEqual(self.tenant.notification_set.count(), 1)
