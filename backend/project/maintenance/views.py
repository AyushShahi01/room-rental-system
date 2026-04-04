from rest_framework import generics
from .models import MaintenanceRequest
from .serializers import MaintenanceSerializer
from rest_framework.views import APIView
from rest_framework.response import Response

class MaintenanceListCreateView(generics.ListCreateAPIView):
    queryset = MaintenanceRequest.objects.all()
    serializer_class = MaintenanceSerializer

class MaintenanceDetailView(generics.RetrieveAPIView):
    queryset = MaintenanceRequest.objects.all()
    serializer_class = MaintenanceSerializer

class MaintenanceStatusUpdateView(APIView):
    def patch(self, request, pk): return Response({"message": "Update status"})

class MyMaintenanceView(generics.ListAPIView):
    serializer_class = MaintenanceSerializer
    def get_queryset(self): return MaintenanceRequest.objects.filter(tenant=self.request.user)

class RoomMaintenanceView(generics.ListAPIView):
    serializer_class = MaintenanceSerializer
    def get_queryset(self): return MaintenanceRequest.objects.filter(room_id=self.kwargs['room_id'])
