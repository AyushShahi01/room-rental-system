from rest_framework import generics, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.exceptions import PermissionDenied
from django.shortcuts import get_object_or_404
from django.db.models import Sum, Value, DecimalField
from django.db.models.functions import Coalesce
from django.utils import timezone
from rooms.models import Room
from .models import RentRecord
from .serializers import RentRecordSerializer


class RentRecordListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = RentRecordSerializer

    def get_queryset(self):
        # Automatically update overdue statuses before listing
        RentRecord.update_overdue()

        user = self.request.user
        if user.role == 'admin':
            qs = RentRecord.objects.select_related('room', 'tenant').all()
        elif user.role == 'landlord':
            qs = RentRecord.objects.select_related('room', 'tenant').filter(room__landlord=user)
        else:
            # Tenant
            qs = RentRecord.objects.select_related('room', 'tenant').filter(tenant=user)

        # Filters
        month = self.request.query_params.get('month')
        year = self.request.query_params.get('year')
        room_id = self.request.query_params.get('room')
        tenant_id = self.request.query_params.get('tenant')
        status_param = self.request.query_params.get('status')

        if month:
            qs = qs.filter(billing_month=month)
        if year:
            qs = qs.filter(billing_year=year)
        if room_id:
            qs = qs.filter(room_id=room_id)
        if tenant_id:
            qs = qs.filter(tenant_id=tenant_id)
        if status_param:
            qs = qs.filter(status=status_param)

        return qs

    def perform_create(self, serializer):
        user = self.request.user
        if user.role not in ['landlord', 'admin']:
            raise PermissionDenied("Only landlords and administrators can create rent records.")

        room = serializer.validated_data.get('room')
        if user.role == 'landlord' and room.landlord_id != user.id:
            raise PermissionDenied("You can only create rent records for rooms that you own.")

        serializer.save()


class RentRecordDetailView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = RentRecordSerializer

    def get_queryset(self):
        # Automatically update overdue statuses before detail lookup
        RentRecord.update_overdue()

        user = self.request.user
        if user.role == 'admin':
            return RentRecord.objects.select_related('room', 'tenant').all()
        elif user.role == 'landlord':
            return RentRecord.objects.select_related('room', 'tenant').filter(room__landlord=user)
        else:
            return RentRecord.objects.select_related('room', 'tenant').filter(tenant=user)

    def check_object_permissions(self, request, obj):
        super().check_object_permissions(request, obj)
        user = request.user

        # Write operations are restricted to landlords and admins
        if request.method not in ['GET', 'HEAD', 'OPTIONS']:
            if user.role not in ['landlord', 'admin']:
                raise PermissionDenied("Only landlords and administrators can modify rent records.")
            if user.role == 'landlord' and obj.room.landlord_id != user.id:
                raise PermissionDenied("You can only modify rent records for rooms that you own.")

    def perform_update(self, serializer):
        old_instance = self.get_object()
        old_status = old_instance.status
        instance = serializer.save()

        if old_status != RentRecord.STATUS_PAID and instance.status == RentRecord.STATUS_PAID:
            try:
                from notifications.helpers import create_notification
                create_notification(
                    instance.tenant,
                    f"Rent for {instance.room.title} ({instance.billing_month}/{instance.billing_year}) has been marked as paid!"
                )

                from messaging.models import Message as ChatMessage
                from messaging.serializers import MessageSerializer
                from channels.layers import get_channel_layer
                from asgiref.sync import async_to_sync

                chat_message = ChatMessage.objects.create(
                    sender=instance.room.landlord,
                    receiver=instance.tenant,
                    content=f"✅ Rent payment of Rs. {instance.amount} for Room '{instance.room.title}' ({instance.billing_month}/{instance.billing_year}) has been marked as paid. Thank you!"
                )

                channel_layer = get_channel_layer()
                if channel_layer:
                    serialized_msg = MessageSerializer(chat_message).data
                    group_msg = {
                        "type": "chat_message",
                        "message": serialized_msg
                    }
                    async_to_sync(channel_layer.group_send)(f"user_{instance.tenant.id}", group_msg)
                    async_to_sync(channel_layer.group_send)(f"user_{instance.room.landlord.id}", group_msg)
            except BaseException as e:
                import logging
                logging.getLogger(__name__).error(f"Failed to send rent payment confirmation: {e}")



class RentDashboardView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        if user.role not in ['landlord', 'admin']:
            return Response({'error': 'Access denied. Landlord or Admin role required.'}, status=status.HTTP_403_FORBIDDEN)

        # Sync overdue records before calculating stats
        RentRecord.update_overdue()

        # Base filter for rent records
        if user.role == 'admin':
            records = RentRecord.objects.all()
            rooms = Room.objects.all()
        else:
            records = RentRecord.objects.filter(room__landlord=user)
            rooms = Room.objects.filter(landlord=user)

        # 1. Total rent collected & total pending rent
        total_collected = records.aggregate(
            total=Coalesce(Sum('amount_paid'), Value(0.00), output_field=DecimalField())
        )['total']

        total_billed = records.aggregate(
            total=Coalesce(Sum('amount'), Value(0.00), output_field=DecimalField())
        )['total']

        total_pending = total_billed - total_collected

        # 2. Monthly rent collection
        monthly_stats = records.values('billing_year', 'billing_month').annotate(
            collected=Coalesce(Sum('amount_paid'), Value(0.00), output_field=DecimalField()),
            total=Coalesce(Sum('amount'), Value(0.00), output_field=DecimalField())
        ).order_by('-billing_year', '-billing_month')

        monthly_rent_collection = []
        for stat in monthly_stats:
            monthly_rent_collection.append({
                'billing_year': stat['billing_year'],
                'billing_month': stat['billing_month'],
                'collected': stat['collected'],
                'pending': stat['total'] - stat['collected']
            })

        # 3. Room-wise rent collection
        room_stats = records.values('room__id', 'room__title').annotate(
            collected=Coalesce(Sum('amount_paid'), Value(0.00), output_field=DecimalField()),
            total=Coalesce(Sum('amount'), Value(0.00), output_field=DecimalField())
        ).order_by('-collected')

        room_wise_rent_collection = []
        for stat in room_stats:
            room_wise_rent_collection.append({
                'room_id': stat['room__id'],
                'room_title': stat['room__title'],
                'collected': stat['collected'],
                'pending': stat['total'] - stat['collected']
            })

        # 4. Occupied and vacant rooms count
        occupied_rooms_count = rooms.filter(is_available=False).count()
        vacant_rooms_count = rooms.filter(is_available=True).count()

        # 5. List of tenants with overdue rent (rent records marked as overdue)
        overdue_records = records.filter(status=RentRecord.STATUS_OVERDUE)
        overdue_serializer = RentRecordSerializer(overdue_records, many=True, context={'request': request})

        return Response({
            'total_rent_collected': total_collected,
            'total_pending_rent': total_pending,
            'monthly_rent_collection': monthly_rent_collection,
            'room_wise_rent_collection': room_wise_rent_collection,
            'occupied_rooms_count': occupied_rooms_count,
            'vacant_rooms_count': vacant_rooms_count,
            'overdue_tenants': overdue_serializer.data
        }, status=status.HTTP_200_OK)
