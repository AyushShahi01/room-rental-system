from rest_framework import generics
from rest_framework.permissions import AllowAny
from drf_spectacular.utils import extend_schema
from .models import Room, RoomImage
from .serializers import (
    RoomSerializer,
    RoomImageSerializer,
    RoomRecommendationRequestSerializer,
    RoomRecommendationResponseSerializer,
)
from rest_framework.views import APIView
from rest_framework.response import Response
from .utils.recommendation import recommend_rooms

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


class RoomImageListCreateView(generics.ListCreateAPIView):
    serializer_class = RoomImageSerializer

    def get_queryset(self):
        return RoomImage.objects.filter(room_id=self.kwargs['room_id'])

    def perform_create(self, serializer):
        serializer.save(room_id=self.kwargs['room_id'])


class RecommendedRoomsView(APIView):
    permission_classes = [AllowAny]

    @extend_schema(
        request=RoomRecommendationRequestSerializer,
        responses={200: RoomRecommendationResponseSerializer},
    )
    def post(self, request):
        serializer = RoomRecommendationRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        preferences = serializer.validated_data.copy()
        limit = preferences.pop('limit', 10)

        rooms = Room.objects.filter(is_available=True)
        scored_rooms = recommend_rooms(rooms, preferences)
        top_results = scored_rooms[:limit]

        response_data = {
            'count': len(top_results),
            'results': [
                {
                    'room': RoomSerializer(item.room, context={'request': request}).data,
                    'cosine_similarity': item.cosine_similarity,
                    'location_score': item.location_score,
                    'combined_score': item.combined_score,
                }
                for item in top_results
            ],
        }
        return Response(response_data)
