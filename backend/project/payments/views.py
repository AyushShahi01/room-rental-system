from rest_framework import generics, status
from .models import Payment
from .serializers import PaymentSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from decimal import Decimal, InvalidOperation
from bookings.models import Booking
from notifications.helpers import create_notification
from .gateways.esewa import EsewaGatewayError, check_transaction_status
from .gateways.khalti import KhaltiGatewayError, lookup_payment

class PaymentListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = PaymentSerializer

    def get_queryset(self):
        user = self.request.user
        return Payment.objects.filter(booking__tenant=user) | Payment.objects.filter(booking__room__landlord=user)

    def perform_create(self, serializer):
        payment = serializer.save(status=Payment.STATUS_PENDING)
        create_notification(
            payment.booking.room.landlord,
            f'Payment of NPR {payment.amount} received for {payment.booking.room.title}.',
        )

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
        create_notification(payment.booking.tenant, f'Your payment of NPR {payment.amount} has been verified.')
        return Response({'message': 'Payment verified.'}, status=status.HTTP_200_OK)


def _parse_amount(value):
    try:
        amount = Decimal(str(value))
    except (InvalidOperation, TypeError):
        return None
    if amount <= 0:
        return None
    return amount


def _gateway_payment_response(payment, message):
    return Response(
        {
            'message': message,
            'payment': PaymentSerializer(payment).data,
        },
        status=status.HTTP_200_OK,
    )


class KhaltiVerifyView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        pidx = request.data.get('pidx')
        amount = _parse_amount(request.data.get('amount'))
        booking_id = request.data.get('booking_id')

        if not pidx or amount is None or not booking_id:
            return Response({'error': 'pidx, amount, and booking_id are required.'}, status=status.HTTP_400_BAD_REQUEST)

        booking = get_object_or_404(Booking, pk=booking_id, tenant=request.user)

        try:
            payload = lookup_payment(pidx)
        except KhaltiGatewayError as exc:
            return Response({'error': str(exc)}, status=status.HTTP_502_BAD_GATEWAY)

        gateway_amount = payload.get('total_amount')
        expected_paisa = int(amount * Decimal('100'))
        if gateway_amount != expected_paisa:
            payment = Payment.objects.create(
                booking=booking,
                amount=amount,
                status=Payment.STATUS_FAILED,
                payment_gateway=Payment.GATEWAY_KHALTI,
                transaction_token=pidx,
                gateway_response=payload,
            )
            return Response(
                {'error': 'Payment amount mismatch.', 'payment': PaymentSerializer(payment).data},
                status=status.HTTP_400_BAD_REQUEST,
            )

        gateway_status = payload.get('status')
        payment_status = Payment.STATUS_VERIFIED if gateway_status == 'Completed' else Payment.STATUS_FAILED
        payment, _ = Payment.objects.update_or_create(
            booking=booking,
            transaction_token=pidx,
            defaults={
                'amount': amount,
                'status': payment_status,
                'payment_gateway': Payment.GATEWAY_KHALTI,
                'gateway_response': payload,
            },
        )

        if payment.status == Payment.STATUS_VERIFIED:
            create_notification(booking.tenant, f'Your payment of NPR {payment.amount} has been verified.')
            return _gateway_payment_response(payment, 'Khalti payment verified.')

        return _gateway_payment_response(payment, 'Khalti payment could not be verified.')


class EsewaVerifyView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        transaction_uuid = request.data.get('transaction_uuid')
        amount = _parse_amount(request.data.get('amount'))
        booking_id = request.data.get('booking_id')

        if not transaction_uuid or amount is None or not booking_id:
            return Response({'error': 'transaction_uuid, amount, and booking_id are required.'}, status=status.HTTP_400_BAD_REQUEST)

        booking = get_object_or_404(Booking, pk=booking_id, tenant=request.user)

        try:
            payload = check_transaction_status(transaction_uuid, str(amount))
        except EsewaGatewayError as exc:
            return Response({'error': str(exc)}, status=status.HTTP_502_BAD_GATEWAY)

        gateway_amount = _parse_amount(payload.get('total_amount'))
        if gateway_amount != amount:
            payment = Payment.objects.create(
                booking=booking,
                amount=amount,
                status=Payment.STATUS_FAILED,
                payment_gateway=Payment.GATEWAY_ESEWA,
                transaction_token=transaction_uuid,
                gateway_response=payload,
            )
            return Response(
                {'error': 'Payment amount mismatch.', 'payment': PaymentSerializer(payment).data},
                status=status.HTTP_400_BAD_REQUEST,
            )

        payment_status = Payment.STATUS_VERIFIED if payload.get('status') == 'COMPLETE' else Payment.STATUS_FAILED
        payment, _ = Payment.objects.update_or_create(
            booking=booking,
            transaction_token=transaction_uuid,
            defaults={
                'amount': amount,
                'status': payment_status,
                'payment_gateway': Payment.GATEWAY_ESEWA,
                'gateway_response': payload,
            },
        )

        if payment.status == Payment.STATUS_VERIFIED:
            create_notification(booking.tenant, f'Your payment of NPR {payment.amount} has been verified.')
            return _gateway_payment_response(payment, 'eSewa payment verified.')

        return _gateway_payment_response(payment, 'eSewa payment could not be verified.')
