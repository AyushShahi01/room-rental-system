from rest_framework import generics
from .models import Payment
from .serializers import PaymentSerializer
from rest_framework.views import APIView
from rest_framework.response import Response

class PaymentListCreateView(generics.ListCreateAPIView):
    queryset = Payment.objects.all()
    serializer_class = PaymentSerializer

class PaymentDetailView(generics.RetrieveAPIView):
    queryset = Payment.objects.all()
    serializer_class = PaymentSerializer

class MyPaymentsView(generics.ListAPIView):
    serializer_class = PaymentSerializer
    def get_queryset(self): return Payment.objects.none()

class BookingPaymentsView(generics.ListAPIView):
    serializer_class = PaymentSerializer
    def get_queryset(self): return Payment.objects.filter(booking_id=self.kwargs['booking_id'])

class VerifyPaymentView(APIView):
    def patch(self, request, pk): return Response({"message": "Verify payment"})
