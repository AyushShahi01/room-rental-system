from rest_framework import generics, status
from drf_spectacular.utils import extend_schema
from .models import MaintenanceRequest
from .serializers import MaintenanceSerializer, MaintenanceImageUploadSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from users.permissions import IsTenant, IsLandlord
from notifications.helpers import create_notification

class MaintenanceListCreateView(generics.ListCreateAPIView):
    serializer_class = MaintenanceSerializer
    parser_classes = (MultiPartParser, FormParser, JSONParser)

    def get_permissions(self):
        if self.request.method == 'POST':
            return [IsAuthenticated(), IsTenant()]
        return [IsAuthenticated()]

    def get_queryset(self):
        user = self.request.user
        return MaintenanceRequest.objects.filter(tenant=user) | MaintenanceRequest.objects.filter(room__landlord=user)

    def perform_create(self, serializer):
        maintenance = serializer.save(tenant=self.request.user, status=MaintenanceRequest.STATUS_PENDING)
        create_notification(maintenance.room.landlord, f'New maintenance request for {maintenance.room.title}.')

class MaintenanceDetailView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = MaintenanceSerializer

    def get_queryset(self):
        user = self.request.user
        return MaintenanceRequest.objects.filter(tenant=user) | MaintenanceRequest.objects.filter(room__landlord=user)

class MaintenanceStatusUpdateView(APIView):
    permission_classes = [IsAuthenticated, IsLandlord]

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
        create_notification(maintenance.tenant, f'Your maintenance request status: {maintenance.status}.')
        return Response({'message': 'Maintenance status updated.'}, status=status.HTTP_200_OK)

class MaintenanceImageUploadView(APIView):
    permission_classes = [IsAuthenticated, IsTenant]
    parser_classes = (MultiPartParser, FormParser)

    @extend_schema(
        request={
            'multipart/form-data': {
                'type': 'object',
                'properties': {
                    'image': {
                        'type': 'string',
                        'format': 'binary',
                        'description': 'Image file to attach to this maintenance request',
                    }
                },
                'required': ['image'],
            }
        },
        responses={200: MaintenanceSerializer}
    )
    def post(self, request, pk):
        maintenance = get_object_or_404(MaintenanceRequest, pk=pk, tenant=request.user)
        if 'image' not in request.FILES:
            return Response({'error': 'No file uploaded under key "image".'}, status=status.HTTP_400_BAD_REQUEST)
        
        maintenance.image = request.FILES['image']
        maintenance.save(update_fields=['image'])
        return Response(MaintenanceSerializer(maintenance).data, status=status.HTTP_200_OK)

class MyMaintenanceView(generics.ListAPIView):
    permission_classes = [IsAuthenticated, IsTenant]
    serializer_class = MaintenanceSerializer
    def get_queryset(self): return MaintenanceRequest.objects.filter(tenant=self.request.user)

class RoomMaintenanceView(generics.ListAPIView):
    permission_classes = [IsAuthenticated, IsLandlord]
    serializer_class = MaintenanceSerializer
    def get_queryset(self):
        return MaintenanceRequest.objects.filter(room_id=self.kwargs['room_id'], room__landlord=self.request.user)
