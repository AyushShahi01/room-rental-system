from rest_framework import generics, status
from .models import Agreement
from .serializers import AgreementSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.exceptions import PermissionDenied
from django.shortcuts import get_object_or_404
from django.utils import timezone
from users.permissions import IsTenant, IsLandlord
from notifications.helpers import create_notification
from .utils import generate_agreement_content

class AgreementListCreateView(generics.ListCreateAPIView):
    serializer_class = AgreementSerializer

    def get_permissions(self):
        if self.request.method == 'POST':
            return [IsAuthenticated(), IsLandlord()]
        return [IsAuthenticated()]

    def get_queryset(self):
        user = self.request.user
        return Agreement.objects.filter(booking__tenant=user) | Agreement.objects.filter(booking__room__landlord=user)

    def perform_create(self, serializer):
        booking = serializer.validated_data['booking']
        content = serializer.validated_data.get('content') or generate_agreement_content(booking)
        agreement = serializer.save(content=content)
        create_notification(agreement.booking.tenant, 'A lease agreement has been created for your booking.')

class AgreementDetailView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = AgreementSerializer

    def get_queryset(self):
        user = self.request.user
        return Agreement.objects.filter(booking__tenant=user) | Agreement.objects.filter(booking__room__landlord=user)

class SignAgreementView(APIView):
    permission_classes = [IsAuthenticated, IsTenant]

    def patch(self, request, pk):
        agreement = get_object_or_404(Agreement, pk=pk, booking__tenant=request.user)
        if agreement.is_signed:
            return Response({'message': 'Agreement already signed.'}, status=status.HTTP_200_OK)

        agreement.is_signed = True
        agreement.signed_at = timezone.now()
        agreement.save(update_fields=['is_signed', 'signed_at'])
        create_notification(agreement.booking.room.landlord, 'Tenant has signed the lease agreement.')
        return Response({'message': 'Agreement signed.'}, status=status.HTTP_200_OK)

class BookingAgreementView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = AgreementSerializer

    def get_object(self):
        booking_id = self.kwargs['booking_id']
        user = self.request.user
        return get_object_or_404(
            Agreement,
            booking_id=booking_id,
            booking__tenant=user,
        )
