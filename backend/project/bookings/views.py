from rest_framework import generics, status
from .models import Booking
from .serializers import BookingSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from users.permissions import IsTenant, IsLandlord, IsEmailVerified
from notifications.helpers import create_notification


def _booking_for_user_or_404(user, pk):
    from rest_framework.exceptions import PermissionDenied
    if user.role != 'landlord':
        raise PermissionDenied("Only landlords can approve or reject booking requests.")
    return get_object_or_404(
        Booking,
        pk=pk,
        room__landlord=user,
    )

class BookingListCreateView(generics.ListCreateAPIView):
    serializer_class = BookingSerializer

    def get_permissions(self):
        if self.request.method == 'POST':
            return [IsAuthenticated(), IsTenant(), IsEmailVerified()]
        return [IsAuthenticated(), IsEmailVerified()]

    def get_queryset(self):
        user = self.request.user
        if user.role == 'landlord':
            return Booking.objects.filter(room__landlord=user)
        return Booking.objects.filter(tenant=user)

    def perform_create(self, serializer):
        from rest_framework.exceptions import PermissionDenied
        if self.request.user.role != 'tenant':
            raise PermissionDenied("Only tenants can create bookings.")
        booking = serializer.save(tenant=self.request.user, status=Booking.STATUS_PENDING)
        create_notification(
            booking.room.landlord,
            f'New booking request from {booking.tenant.username} for {booking.room.title}.',
        )

        # Create an automatic chat message connecting them
        from messaging.models import Message as ChatMessage
        from messaging.serializers import MessageSerializer
        from channels.layers import get_channel_layer
        from asgiref.sync import async_to_sync

        chat_message = ChatMessage.objects.create(
            sender=self.request.user,
            receiver=booking.room.landlord,
            content=f"Hello, I have submitted a booking request for your room: '{booking.room.title}'.",
            booking_id=booking.id
        )

        # Broadcast the message to both user groups via WebSockets
        try:
            channel_layer = get_channel_layer()
            if channel_layer:
                serialized_msg = MessageSerializer(chat_message).data
                group_msg = {
                    "type": "chat_message",
                    "message": serialized_msg
                }
                async_to_sync(channel_layer.group_send)(f"user_{booking.tenant.id}", group_msg)
                async_to_sync(channel_layer.group_send)(f"user_{booking.room.landlord.id}", group_msg)
        except BaseException as e:
            import logging
            logging.getLogger(__name__).error(f"Failed to broadcast booking message: {e}")

class BookingDetailView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated, IsEmailVerified]
    serializer_class = BookingSerializer

    def get_queryset(self):
        user = self.request.user
        if user.role == 'landlord':
            return Booking.objects.filter(room__landlord=user)
        return Booking.objects.filter(tenant=user)

class BookingApproveView(APIView):
    permission_classes = [IsAuthenticated, IsLandlord, IsEmailVerified]

    def patch(self, request, pk):
        booking = _booking_for_user_or_404(request.user, pk)
        if booking.status != Booking.STATUS_PENDING:
            return Response({'error': 'Only pending bookings can be approved.'}, status=status.HTTP_400_BAD_REQUEST)

        rent_start_date_str = request.data.get('rent_start_date')
        if not rent_start_date_str:
            return Response({'error': 'Rent start date is required to approve the booking.'}, status=status.HTTP_400_BAD_REQUEST)

        import datetime
        try:
            rent_start_date = datetime.datetime.strptime(rent_start_date_str, '%Y-%m-%d').date()
        except ValueError:
            return Response({'error': 'Invalid date format. Use YYYY-MM-DD.'}, status=status.HTTP_400_BAD_REQUEST)

        from django.utils import timezone
        booking.status = Booking.STATUS_APPROVED
        booking.rent_start_date = rent_start_date
        booking.booked_date = timezone.localdate()
        booking.save(update_fields=['status', 'rent_start_date', 'booked_date'])

        # Auto-flip room availability to False
        room = booking.room
        room.is_available = False
        room.save(update_fields=['is_available'])
        create_notification(booking.tenant, f'Your booking for {booking.room.title} has been approved!')

        # Auto-create Agreement from Room template terms
        from agreements.models import Agreement
        from agreements.utils import generate_agreement_content
        try:
            # Clear any pre-existing/stale agreement for this booking to avoid UniqueConstraint errors
            Agreement.objects.filter(booking=booking).delete()

            content = generate_agreement_content(
                booking,
                rent_price=room.price,
                house_rules=room.house_rules,
                additional_description=room.additional_description
            )
            Agreement.objects.create(
                booking=booking,
                content=content,
                rent_price=room.price,
                rent_mode=room.rent_mode,
                fixed_duration_type=room.fixed_duration_type,
                fixed_duration_value=room.fixed_duration_value,
                initial_rent=room.initial_rent,
                increment_every=room.increment_every,
                increment_type=room.increment_type,
                increase_by=room.increase_by,
                house_rules=room.house_rules or '',
                additional_description=room.additional_description or '',
                landlord_is_signed=True,
                landlord_signed_at=timezone.now()
            )
            create_notification(booking.tenant, 'A lease agreement has been auto-generated for your booking.')
        except BaseException as e:
            import logging
            logging.getLogger(__name__).error(f"Failed to auto-create lease agreement on booking approval: {e}")

        # Sync rent records immediately
        from payments.utils import sync_rent_records_for_booking
        try:
            sync_rent_records_for_booking(booking)
        except BaseException as e:
            import logging
            logging.getLogger(__name__).error(f"Failed to sync rent records on booking approval: {e}")

        return Response({'message': 'Booking approved.'}, status=status.HTTP_200_OK)

class BookingRejectView(APIView):
    permission_classes = [IsAuthenticated, IsLandlord, IsEmailVerified]

    def patch(self, request, pk):
        booking = _booking_for_user_or_404(request.user, pk)
        if booking.status != Booking.STATUS_PENDING:
            return Response({'error': 'Only pending bookings can be rejected.'}, status=status.HTTP_400_BAD_REQUEST)

        booking.status = Booking.STATUS_REJECTED
        booking.save(update_fields=['status'])
        create_notification(booking.tenant, f'Your booking for {booking.room.title} has been rejected.')
        return Response({'message': 'Booking rejected.'}, status=status.HTTP_200_OK)

class BookingCancelView(APIView):
    permission_classes = [IsAuthenticated, IsEmailVerified]

    def patch(self, request, pk):
        booking = get_object_or_404(Booking, pk=pk)
        
        is_tenant = booking.tenant == request.user
        is_landlord = booking.room.landlord == request.user
        
        if not (is_tenant or is_landlord):
            return Response({'error': 'You do not have permission to cancel this booking.'}, status=status.HTTP_403_FORBIDDEN)

        if booking.status not in (Booking.STATUS_PENDING, Booking.STATUS_APPROVED):
            return Response({'error': 'Only pending or approved bookings can be cancelled.'}, status=status.HTTP_400_BAD_REQUEST)

        was_approved = booking.status == Booking.STATUS_APPROVED

        booking.status = Booking.STATUS_CANCELLED
        booking.save(update_fields=['status'])

        # Free the room if the booking was previously approved
        if was_approved:
            room = booking.room
            room.is_available = True
            room.save(update_fields=['is_available'])

        # Send appropriate notification to the other party
        if is_tenant:
            create_notification(booking.room.landlord, f'Booking for {booking.room.title} has been cancelled by the tenant.')
        else:
            create_notification(booking.tenant, f'Your booking for {booking.room.title} has been cancelled by the landlord.')

        return Response({'message': 'Booking cancelled.'}, status=status.HTTP_200_OK)

class MyBookingsView(generics.ListAPIView):
    permission_classes = [IsAuthenticated, IsTenant, IsEmailVerified]
    serializer_class = BookingSerializer
    def get_queryset(self): return Booking.objects.filter(tenant=self.request.user)

class IncomingBookingsView(generics.ListAPIView):
    permission_classes = [IsAuthenticated, IsLandlord, IsEmailVerified]
    serializer_class = BookingSerializer
    def get_queryset(self): return Booking.objects.filter(room__landlord=self.request.user)
