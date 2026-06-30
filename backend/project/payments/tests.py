from unittest.mock import patch

from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from bookings.models import Booking
from rooms.models import Room
from users.models import CustomUser
from .models import Payment


class PaymentTests(APITestCase):
    def setUp(self):
        self.tenant = CustomUser.objects.create_user(username='tenant', password='password', role='tenant')
        self.other_tenant = CustomUser.objects.create_user(username='other', password='password', role='tenant')
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
        self.booking = Booking.objects.create(tenant=self.tenant, room=self.room, status=Booking.STATUS_APPROVED)

    def test_create_payment(self):
        self.client.force_authenticate(user=self.tenant)
        response = self.client.post(reverse('payment-list-create'), {'booking': self.booking.id, 'amount': '100.00'})

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['payment_gateway'], Payment.GATEWAY_MANUAL)
        self.assertEqual(self.landlord.notification_set.count(), 1)

    @patch('payments.views.lookup_payment')
    def test_khalti_verify_success(self, lookup_payment):
        lookup_payment.return_value = {
            'pidx': 'abc',
            'total_amount': 10000,
            'status': 'Completed',
            'transaction_id': 'txn-1',
        }
        self.client.force_authenticate(user=self.tenant)
        response = self.client.post(reverse('khalti-verify'), {
            'pidx': 'abc',
            'amount': '100.00',
            'booking_id': self.booking.id,
        })

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        payment = Payment.objects.get(transaction_token='abc')
        self.assertEqual(payment.status, Payment.STATUS_VERIFIED)
        self.assertEqual(payment.payment_gateway, Payment.GATEWAY_KHALTI)

    @patch('payments.views.lookup_payment')
    def test_khalti_amount_mismatch_fails(self, lookup_payment):
        lookup_payment.return_value = {'pidx': 'abc', 'total_amount': 5000, 'status': 'Completed'}
        self.client.force_authenticate(user=self.tenant)
        response = self.client.post(reverse('khalti-verify'), {
            'pidx': 'abc',
            'amount': '100.00',
            'booking_id': self.booking.id,
        })

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(Payment.objects.get(transaction_token='abc').status, Payment.STATUS_FAILED)

    @patch('payments.views.check_transaction_status')
    def test_esewa_verify_success(self, check_transaction_status):
        check_transaction_status.return_value = {
            'product_code': 'EPAYTEST',
            'transaction_uuid': 'uuid-1',
            'total_amount': 100.0,
            'status': 'COMPLETE',
            'ref_id': 'ref-1',
        }
        self.client.force_authenticate(user=self.tenant)
        response = self.client.post(reverse('esewa-verify'), {
            'transaction_uuid': 'uuid-1',
            'amount': '100.00',
            'booking_id': self.booking.id,
        })

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        payment = Payment.objects.get(transaction_token='uuid-1')
        self.assertEqual(payment.status, Payment.STATUS_VERIFIED)
        self.assertEqual(payment.payment_gateway, Payment.GATEWAY_ESEWA)

    @patch('payments.views.check_transaction_status')
    def test_esewa_pending_creates_failed_payment(self, check_transaction_status):
        check_transaction_status.return_value = {
            'transaction_uuid': 'uuid-1',
            'total_amount': 100.0,
            'status': 'PENDING',
        }
        self.client.force_authenticate(user=self.tenant)
        response = self.client.post(reverse('esewa-verify'), {
            'transaction_uuid': 'uuid-1',
            'amount': '100.00',
            'booking_id': self.booking.id,
        })

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(Payment.objects.get(transaction_token='uuid-1').status, Payment.STATUS_FAILED)

    @patch('payments.views.lookup_payment')
    def test_gateway_verify_requires_booking_owner(self, lookup_payment):
        self.client.force_authenticate(user=self.other_tenant)
        response = self.client.post(reverse('khalti-verify'), {
            'pidx': 'abc',
            'amount': '100.00',
            'booking_id': self.booking.id,
        })

        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        lookup_payment.assert_not_called()
