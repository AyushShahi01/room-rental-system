from rest_framework import generics
from .models import Agreement
from .serializers import AgreementSerializer
from rest_framework.views import APIView
from rest_framework.response import Response

class AgreementListCreateView(generics.ListCreateAPIView):
    queryset = Agreement.objects.all()
    serializer_class = AgreementSerializer

class AgreementDetailView(generics.RetrieveAPIView):
    queryset = Agreement.objects.all()
    serializer_class = AgreementSerializer

class SignAgreementView(APIView):
    def patch(self, request, pk): return Response({"message": "Sign agreement"})

class BookingAgreementView(generics.RetrieveAPIView):
    serializer_class = AgreementSerializer
    def get_object(self): return Agreement.objects.get(booking_id=self.kwargs['booking_id'])
