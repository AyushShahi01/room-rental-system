from rest_framework import generics
from .models import Room
from .serializers import RoomSerializer
from rest_framework.views import APIView
from rest_framework.response import Response

class RoomListCreateView(generics.ListCreateAPIView):
    queryset = Room.objects.all()
    serializer_class = RoomSerializer

class RoomDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Room.objects.all()
    serializer_class = RoomSerializer

class MyRoomsView(generics.ListAPIView):
    serializer_class = RoomSerializer
    def get_queryset(self):
        return Room.objects.filter(landlord=self.request.user)

class RoomAvailabilityView(APIView):
    def patch(self, request, pk):
        return Response({"message": "Toggle availability"})
