from rest_framework import generics
from .models import Booking
from .serializers import BookingSerializer
from rest_framework.views import APIView
from rest_framework.response import Response

class BookingListCreateView(generics.ListCreateAPIView):
    queryset = Booking.objects.all()
    serializer_class = BookingSerializer

class BookingDetailView(generics.RetrieveAPIView):
    queryset = Booking.objects.all()
    serializer_class = BookingSerializer

class BookingApproveView(APIView):
    def patch(self, request, pk): return Response({"message": "Approve"})

class BookingRejectView(APIView):
    def patch(self, request, pk): return Response({"message": "Reject"})

class BookingCancelView(APIView):
    def patch(self, request, pk): return Response({"message": "Cancel"})

class MyBookingsView(generics.ListAPIView):
    serializer_class = BookingSerializer
    def get_queryset(self): return Booking.objects.filter(tenant=self.request.user)

class IncomingBookingsView(generics.ListAPIView):
    serializer_class = BookingSerializer
    def get_queryset(self): return Booking.objects.filter(room__landlord=self.request.user)
