from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from django.contrib.auth import get_user_model

User = get_user_model()


class UserAuthTests(APITestCase):
    def setUp(self):
        self.register_url = reverse('register')
        self.login_url = reverse('login')
        self.logout_url = reverse('logout')
        self.refresh_url = reverse('token_refresh')
        self.me_url = reverse('me')
        self.change_password_url = reverse('change-password')

        self.user_data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'testpassword123',
            'role': 'tenant',
        }

    def test_registration_returns_tokens(self):
        response = self.client.post(self.register_url, self.user_data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('tokens', response.data)
        self.assertIn('access', response.data['tokens'])
        self.assertIn('refresh', response.data['tokens'])
        self.assertIn('user', response.data)
        self.assertEqual(response.data['user']['role'], 'tenant')
        self.assertEqual(response.data['user']['tenant_id'], response.data['user']['id'])
        self.assertIsNone(response.data['user']['landlord_id'])

    def test_login_with_username_returns_tokens(self):
        User.objects.create_user(**self.user_data)
        response = self.client.post(self.login_url, {
            'username': 'testuser',
            'password': 'testpassword123'
        })
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('tokens', response.data)
        self.assertIn('access', response.data['tokens'])
        self.assertIn('refresh', response.data['tokens'])
        self.assertEqual(response.data['user']['role'], 'tenant')

    def test_login_with_email_returns_tokens(self):
        User.objects.create_user(**self.user_data)
        response = self.client.post(self.login_url, {
            'email': 'test@example.com',
            'password': 'testpassword123'
        })
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('tokens', response.data)
        self.assertIn('access', response.data['tokens'])
        self.assertIn('refresh', response.data['tokens'])
        self.assertEqual(response.data['user']['role'], 'tenant')

    def test_login_with_username_or_email_as_email_returns_tokens(self):
        User.objects.create_user(**self.user_data)
        response = self.client.post(self.login_url, {
            'usernameOrEmail': 'test@example.com',
            'password': 'testpassword123'
        })
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('tokens', response.data)
        self.assertIn('access', response.data['tokens'])
        self.assertIn('refresh', response.data['tokens'])
        self.assertEqual(response.data['user']['role'], 'tenant')

    def test_login_with_username_or_email_as_username_returns_tokens(self):
        User.objects.create_user(**self.user_data)
        response = self.client.post(self.login_url, {
            'usernameOrEmail': 'testuser',
            'password': 'testpassword123'
        })
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('tokens', response.data)
        self.assertIn('access', response.data['tokens'])
        self.assertIn('refresh', response.data['tokens'])
        self.assertEqual(response.data['user']['role'], 'tenant')

    def test_login_invalid_credentials(self):
        User.objects.create_user(**self.user_data)
        response = self.client.post(self.login_url, {
            'username': 'testuser',
            'password': 'wrongpassword'
        })
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertIn('errors', response.data)

    def test_refresh_returns_new_access(self):
        register_response = self.client.post(self.register_url, self.user_data)
        refresh_token = register_response.data['tokens']['refresh']

        refresh_response = self.client.post(self.refresh_url, {
            'refresh': refresh_token
        })
        self.assertEqual(refresh_response.status_code, status.HTTP_200_OK)
        self.assertIn('access', refresh_response.data)
        self.assertIn('refresh', refresh_response.data)

    def test_logout_blacklists_refresh_token(self):
        register_response = self.client.post(self.register_url, self.user_data)
        refresh_token = register_response.data['tokens']['refresh']
        access_token = register_response.data['tokens']['access']

        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {access_token}')
        logout_response = self.client.post(self.logout_url, {'refresh': refresh_token})
        self.assertEqual(logout_response.status_code, status.HTTP_200_OK)

        refresh_response = self.client.post(self.refresh_url, {'refresh': refresh_token})
        self.assertEqual(refresh_response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_me_requires_auth(self):
        response = self.client.get(self.me_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_me_returns_role_based_ids_for_landlord(self):
        payload = {
            'username': 'owner',
            'email': 'owner@example.com',
            'password': 'ownerpassword123',
            'role': 'landlord',
        }
        register_response = self.client.post(self.register_url, payload)
        access_token = register_response.data['tokens']['access']
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {access_token}')

        me_response = self.client.get(self.me_url)
        self.assertEqual(me_response.status_code, status.HTTP_200_OK)
        self.assertEqual(me_response.data['role'], 'landlord')
        self.assertEqual(me_response.data['landlord_id'], me_response.data['id'])
        self.assertIsNone(me_response.data['tenant_id'])

    def test_registration_rejects_invalid_role_value(self):
        payload = {
            'username': 'badroleuser',
            'email': 'badrole@example.com',
            'password': 'testpassword123',
            'role': 'tenent',
        }
        response = self.client.post(self.register_url, payload)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('role', response.data)

    def test_change_password_success(self):
        register_response = self.client.post(self.register_url, self.user_data)
        access_token = register_response.data['tokens']['access']
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {access_token}')

        response = self.client.post(self.change_password_url, {
            'old_password': 'testpassword123',
            'new_password': 'newstrongpassword123',
            'new_password_confirm': 'newstrongpassword123',
        })

        self.assertEqual(response.status_code, status.HTTP_200_OK)

        login_response = self.client.post(self.login_url, {
            'username': 'testuser',
            'password': 'newstrongpassword123'
        })
        self.assertEqual(login_response.status_code, status.HTTP_200_OK)

    def test_change_password_wrong_old_password(self):
        register_response = self.client.post(self.register_url, self.user_data)
        access_token = register_response.data['tokens']['access']
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {access_token}')

        response = self.client.post(self.change_password_url, {
            'old_password': 'incorrect-old-password',
            'new_password': 'newstrongpassword123',
            'new_password_confirm': 'newstrongpassword123',
        })
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
