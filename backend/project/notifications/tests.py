from unittest.mock import patch

from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from users.models import CustomUser
from .helpers import create_notification
from .models import Notification


class NotificationTests(APITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(username='user', password='password', role='tenant')

    def test_list_and_mark_read(self):
        notification = Notification.objects.create(user=self.user, content='Hello')
        self.client.force_authenticate(user=self.user)

        list_response = self.client.get(reverse('notification-list'))
        self.assertEqual(list_response.status_code, status.HTTP_200_OK)
        self.assertEqual(list_response.data['count'], 1)

        read_response = self.client.patch(reverse('mark-notification-read', kwargs={'pk': notification.pk}))
        self.assertEqual(read_response.status_code, status.HTTP_200_OK)
        notification.refresh_from_db()
        self.assertTrue(notification.is_read)

    def test_read_all(self):
        Notification.objects.create(user=self.user, content='A')
        Notification.objects.create(user=self.user, content='B')
        self.client.force_authenticate(user=self.user)

        response = self.client.patch(reverse('read-all-notifications'))

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(Notification.objects.filter(user=self.user, is_read=False).count(), 0)

    @patch('notifications.helpers.send_push')
    def test_create_notification_clears_invalid_fcm_token(self, send_push):
        UnregisteredError = type('UnregisteredError', (Exception,), {})
        send_push.side_effect = UnregisteredError('invalid token')
        self.user.fcm_token = 'bad-token'
        self.user.save(update_fields=['fcm_token'])

        create_notification(self.user, 'Hello')

        self.user.refresh_from_db()
        self.assertIsNone(self.user.fcm_token)
        self.assertEqual(Notification.objects.filter(user=self.user).count(), 1)
