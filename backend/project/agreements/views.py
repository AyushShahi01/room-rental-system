from django.shortcuts import get_object_or_404
from django.utils import timezone
from rest_framework import generics, status
from rest_framework.exceptions import PermissionDenied
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Agreement
from .serializers import AgreementSerializer


class AgreementListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = AgreementSerializer

    def get_queryset(self):
        user = self.request.user
        return Agreement.objects.filter(booking__tenant=user) | Agreement.objects.filter(
            booking__room__landlord=user
        )

    def perform_create(self, serializer):
        user = self.request.user
        if not hasattr(user, 'role') or user.role != 'landlord':
            raise PermissionDenied('Only landlords can create agreements.')
        serializer.save()


class AgreementDetailView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = AgreementSerializer

    def get_queryset(self):
        user = self.request.user
        return Agreement.objects.filter(booking__tenant=user) | Agreement.objects.filter(
            booking__room__landlord=user
        )


class SignAgreementView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request, pk):
        agreement = get_object_or_404(Agreement, pk=pk, booking__tenant=request.user)
        if agreement.is_signed:
            serializer = AgreementSerializer(agreement)
            return Response(serializer.data, status=status.HTTP_200_OK)

        agreement.is_signed = True
        agreement.signed_at = timezone.now()
        agreement.save(update_fields=['is_signed', 'signed_at'])
        serializer = AgreementSerializer(agreement)
        return Response(serializer.data, status=status.HTTP_200_OK)


class BookingAgreementView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = AgreementSerializer

    def get_object(self):
        booking_id = self.kwargs['booking_id']
        user = self.request.user
        return get_object_or_404(
            Agreement.objects.filter(booking_id=booking_id).filter(
                booking__tenant=user,
            )
            | Agreement.objects.filter(
                booking_id=booking_id,
                booking__room__landlord=user,
            ),
        )
