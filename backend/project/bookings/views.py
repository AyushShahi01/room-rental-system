from rest_framework import generics, status
from .models import Booking
from .serializers import BookingSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from users.permissions import IsTenant, IsLandlord


def _booking_for_user_or_404(user, pk):
    return get_object_or_404(
        Booking,
        pk=pk,
        room__landlord=user,
    )

class BookingListCreateView(generics.ListCreateAPIView):
    serializer_class = BookingSerializer

    def get_permissions(self):
        if self.request.method == 'POST':
            return [IsAuthenticated(), IsTenant()]
        return [IsAuthenticated()]

    def get_queryset(self):
        return Booking.objects.filter(tenant=self.request.user)

    def perform_create(self, serializer):
        serializer.save(tenant=self.request.user, status=Booking.STATUS_PENDING)

class BookingDetailView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = BookingSerializer

    def get_queryset(self):
        user = self.request.user
        return Booking.objects.filter(tenant=user) | Booking.objects.filter(room__landlord=user)

class BookingApproveView(APIView):
    permission_classes = [IsAuthenticated, IsLandlord]

    def patch(self, request, pk):
        booking = _booking_for_user_or_404(request.user, pk)
        if booking.status != Booking.STATUS_PENDING:
            return Response({'error': 'Only pending bookings can be approved.'}, status=status.HTTP_400_BAD_REQUEST)

        booking.status = Booking.STATUS_APPROVED
        booking.save(update_fields=['status'])

        # Auto-flip room availability to False
        room = booking.room
        room.is_available = False
        room.save(update_fields=['is_available'])

        return Response({'message': 'Booking approved.'}, status=status.HTTP_200_OK)

class BookingRejectView(APIView):
    permission_classes = [IsAuthenticated, IsLandlord]

    def patch(self, request, pk):
        booking = _booking_for_user_or_404(request.user, pk)
        if booking.status != Booking.STATUS_PENDING:
            return Response({'error': 'Only pending bookings can be rejected.'}, status=status.HTTP_400_BAD_REQUEST)

        booking.status = Booking.STATUS_REJECTED
        booking.save(update_fields=['status'])
        return Response({'message': 'Booking rejected.'}, status=status.HTTP_200_OK)

class BookingCancelView(APIView):
    permission_classes = [IsAuthenticated, IsTenant]

    def patch(self, request, pk):
        booking = get_object_or_404(Booking, pk=pk, tenant=request.user)
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

        return Response({'message': 'Booking cancelled.'}, status=status.HTTP_200_OK)

class MyBookingsView(generics.ListAPIView):
    permission_classes = [IsAuthenticated, IsTenant]
    serializer_class = BookingSerializer
    def get_queryset(self): return Booking.objects.filter(tenant=self.request.user)

class IncomingBookingsView(generics.ListAPIView):
    permission_classes = [IsAuthenticated, IsLandlord]
    serializer_class = BookingSerializer
    def get_queryset(self): return Booking.objects.filter(room__landlord=self.request.user)
