from rest_framework import generics, status
from .models import Payment
from .serializers import PaymentSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404

class PaymentListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = PaymentSerializer

    def get_queryset(self):
        user = self.request.user
        return Payment.objects.filter(booking__tenant=user) | Payment.objects.filter(booking__room__landlord=user)

    def perform_create(self, serializer):
        serializer.save(status=Payment.STATUS_PENDING)

class PaymentDetailView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = PaymentSerializer

    def get_queryset(self):
        user = self.request.user
        return Payment.objects.filter(booking__tenant=user) | Payment.objects.filter(booking__room__landlord=user)

class MyPaymentsView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = PaymentSerializer
    def get_queryset(self):
        return Payment.objects.filter(booking__tenant=self.request.user)

class BookingPaymentsView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = PaymentSerializer

    def get_queryset(self):
        user = self.request.user
        booking_id = self.kwargs['booking_id']
        return Payment.objects.filter(booking_id=booking_id).filter(booking__tenant=user) | Payment.objects.filter(
            booking_id=booking_id,
            booking__room__landlord=user,
        )

class VerifyPaymentView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request, pk):
        payment = get_object_or_404(Payment, pk=pk, booking__room__landlord=request.user)
        if payment.status != Payment.STATUS_PENDING:
            return Response({'error': 'Only pending payments can be verified.'}, status=status.HTTP_400_BAD_REQUEST)

        payment.status = Payment.STATUS_VERIFIED
        payment.save(update_fields=['status'])
        return Response({'message': 'Payment verified.'}, status=status.HTTP_200_OK)
