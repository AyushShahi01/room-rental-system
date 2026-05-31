from rest_framework import generics, status
from .models import MaintenanceRequest
from .serializers import MaintenanceSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404

class MaintenanceListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = MaintenanceSerializer

    def get_queryset(self):
        user = self.request.user
        return MaintenanceRequest.objects.filter(tenant=user) | MaintenanceRequest.objects.filter(room__landlord=user)

    def perform_create(self, serializer):
        serializer.save(tenant=self.request.user, status=MaintenanceRequest.STATUS_PENDING)

class MaintenanceDetailView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = MaintenanceSerializer

    def get_queryset(self):
        user = self.request.user
        return MaintenanceRequest.objects.filter(tenant=user) | MaintenanceRequest.objects.filter(room__landlord=user)

class MaintenanceStatusUpdateView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request, pk):
        maintenance = get_object_or_404(MaintenanceRequest, pk=pk, room__landlord=request.user)
        new_status = request.data.get('status')
        allowed = {
            MaintenanceRequest.STATUS_IN_PROGRESS,
            MaintenanceRequest.STATUS_RESOLVED,
            MaintenanceRequest.STATUS_REJECTED,
        }

        if new_status not in allowed:
            return Response({'error': 'Invalid status transition.'}, status=status.HTTP_400_BAD_REQUEST)

        maintenance.status = new_status
        maintenance.save(update_fields=['status'])
        return Response({'message': 'Maintenance status updated.'}, status=status.HTTP_200_OK)

class MyMaintenanceView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = MaintenanceSerializer
    def get_queryset(self): return MaintenanceRequest.objects.filter(tenant=self.request.user)

class RoomMaintenanceView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = MaintenanceSerializer
    def get_queryset(self):
        return MaintenanceRequest.objects.filter(room_id=self.kwargs['room_id'], room__landlord=self.request.user)
