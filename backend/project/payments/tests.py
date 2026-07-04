from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from django.utils import timezone
from datetime import timedelta

from rooms.models import Room
from users.models import CustomUser
from .models import RentRecord


class RentTrackerTests(APITestCase):
    def setUp(self):
        self.tenant = CustomUser.objects.create_user(username='tenant', password='password', role='tenant')
        self.other_tenant = CustomUser.objects.create_user(username='other_tenant', password='password', role='tenant')
        self.landlord = CustomUser.objects.create_user(username='landlord', password='password', role='landlord')
        self.other_landlord = CustomUser.objects.create_user(username='other_landlord', password='password', role='landlord')
        
        self.room = Room.objects.create(
            landlord=self.landlord,
            title='Cozy Room',
            description='A cozy room',
            price='12000.00',
            province='Bagmati',
            state='Kathmandu',
            ward_number=7,
        )
        self.other_room = Room.objects.create(
            landlord=self.other_landlord,
            title='Luxury Room',
            description='A luxury room',
            price='20000.00',
            province='Bagmati',
            state='Kathmandu',
            ward_number=8,
        )

    def test_create_rent_record_by_landlord(self):
        self.client.force_authenticate(user=self.landlord)
        due_date = timezone.now().date() + timedelta(days=5)
        response = self.client.post(reverse('rent-list-create'), {
            'tenant': self.tenant.id,
            'room': self.room.id,
            'amount': '12000.00',
            'billing_month': 7,
            'billing_year': 2026,
            'due_date': due_date.isoformat(),
        })
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['status'], RentRecord.STATUS_UNPAID)
        self.assertEqual(response.data['amount_paid'], '0.00')

    def test_create_rent_record_by_tenant_forbidden(self):
        self.client.force_authenticate(user=self.tenant)
        due_date = timezone.now().date() + timedelta(days=5)
        response = self.client.post(reverse('rent-list-create'), {
            'tenant': self.tenant.id,
            'room': self.room.id,
            'amount': '12000.00',
            'billing_month': 7,
            'billing_year': 2026,
            'due_date': due_date.isoformat(),
        })
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_create_rent_record_for_other_landlord_room_forbidden(self):
        self.client.force_authenticate(user=self.landlord)
        due_date = timezone.now().date() + timedelta(days=5)
        response = self.client.post(reverse('rent-list-create'), {
            'tenant': self.tenant.id,
            'room': self.other_room.id,
            'amount': '20000.00',
            'billing_month': 7,
            'billing_year': 2026,
            'due_date': due_date.isoformat(),
        })
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_auto_paid_status_on_creation(self):
        self.client.force_authenticate(user=self.landlord)
        due_date = timezone.now().date() + timedelta(days=5)
        response = self.client.post(reverse('rent-list-create'), {
            'tenant': self.tenant.id,
            'room': self.room.id,
            'amount': '12000.00',
            'amount_paid': '12000.00',
            'billing_month': 7,
            'billing_year': 2026,
            'due_date': due_date.isoformat(),
        })
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['status'], RentRecord.STATUS_PAID)
        self.assertIsNotNone(response.data['payment_date'])

    def test_auto_overdue_status_on_due_date_passed(self):
        # Create an unpaid record in the past
        past_due = timezone.now().date() - timedelta(days=2)
        record = RentRecord.objects.create(
            tenant=self.tenant,
            room=self.room,
            amount='12000.00',
            amount_paid='0.00',
            billing_month=6,
            billing_year=2026,
            due_date=past_due,
            status=RentRecord.STATUS_UNPAID
        )
        
        # When querying listing, it should automatically trigger status update to overdue
        self.client.force_authenticate(user=self.landlord)
        response = self.client.get(reverse('rent-list-create'))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        record.refresh_from_db()
        self.assertEqual(record.status, RentRecord.STATUS_OVERDUE)

    def test_partial_payment_updates_status(self):
        due_date = timezone.now().date() + timedelta(days=5)
        record = RentRecord.objects.create(
            tenant=self.tenant,
            room=self.room,
            amount='12000.00',
            amount_paid='0.00',
            billing_month=7,
            billing_year=2026,
            due_date=due_date,
            status=RentRecord.STATUS_UNPAID
        )
        
        self.client.force_authenticate(user=self.landlord)
        response = self.client.patch(reverse('rent-detail', kwargs={'pk': record.id}), {
            'amount_paid': '5000.00'
        })
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], RentRecord.STATUS_PARTIALLY_PAID)

    def test_landlord_dashboard_stats(self):
        due_date = timezone.now().date() + timedelta(days=5)
        
        # 1 paid record
        RentRecord.objects.create(
            tenant=self.tenant,
            room=self.room,
            amount='10000.00',
            amount_paid='10000.00',
            billing_month=5,
            billing_year=2026,
            due_date=due_date,
            status=RentRecord.STATUS_PAID,
            payment_date=timezone.now().date()
        )
        # 1 partially paid record
        RentRecord.objects.create(
            tenant=self.tenant,
            room=self.room,
            amount='10000.00',
            amount_paid='3000.00',
            billing_month=6,
            billing_year=2026,
            due_date=due_date,
            status=RentRecord.STATUS_PARTIALLY_PAID
        )
        
        # Room is occupied
        self.room.is_available = False
        self.room.save()

        self.client.force_authenticate(user=self.landlord)
        response = self.client.get(reverse('rent-dashboard'))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        self.assertEqual(float(response.data['total_rent_collected']), 13000.00)
        self.assertEqual(float(response.data['total_pending_rent']), 7000.00)
        self.assertEqual(response.data['occupied_rooms_count'], 1)
        self.assertEqual(response.data['vacant_rooms_count'], 0)
        
        # Verify dashboard structures
        self.assertEqual(len(response.data['monthly_rent_collection']), 2)
        self.assertEqual(len(response.data['room_wise_rent_collection']), 1)
