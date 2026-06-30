from rest_framework import generics, status
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
from rest_framework.permissions import IsAuthenticated
from rest_framework.exceptions import PermissionDenied
from django.shortcuts import get_object_or_404
from users.permissions import IsLandlord

class RoomListCreateView(generics.ListCreateAPIView):
    serializer_class = RoomSerializer

    def get_permissions(self):
        if self.request.method == 'GET':
            return [AllowAny()]
        return [IsAuthenticated(), IsLandlord()]

    def get_queryset(self):
        user = self.request.user
        if user and user.is_authenticated:
            queryset = Room.objects.filter(is_available=True) | Room.objects.filter(landlord=user)
        else:
            queryset = Room.objects.filter(is_available=True)

        # Extract search query parameters
        province = self.request.query_params.get('province')
        state = self.request.query_params.get('state')
        city = self.request.query_params.get('city')
        ward_number = self.request.query_params.get('ward_number')
        min_price = self.request.query_params.get('min_price')
        max_price = self.request.query_params.get('max_price')
        furnished_status = self.request.query_params.get('furnished_status')
        gender_preference = self.request.query_params.get('gender_preference')

        # Feature Flags / Amenities
        has_wifi = self.request.query_params.get('has_wifi')
        has_ac = self.request.query_params.get('has_ac')
        has_attached_bathroom = self.request.query_params.get('has_attached_bathroom')
        parking_available = self.request.query_params.get('parking_available')
        food_available = self.request.query_params.get('food_available')
        water_supply_available = self.request.query_params.get('water_supply_available')
        waste_collection_available = self.request.query_params.get('waste_collection_available')

        if province:
            queryset = queryset.filter(province__iexact=province)
        if state:
            queryset = queryset.filter(state__iexact=state)
        if city:
            queryset = queryset.filter(state__iexact=city)
        if ward_number:
            queryset = queryset.filter(ward_number=ward_number)
        if min_price:
            queryset = queryset.filter(price__gte=min_price)
        if max_price:
            queryset = queryset.filter(price__lte=max_price)
        if furnished_status:
            queryset = queryset.filter(furnished_status=furnished_status.lower() == 'true')
        if gender_preference:
            queryset = queryset.filter(gender_preference=gender_preference.lower())
        if has_wifi:
            queryset = queryset.filter(has_wifi=has_wifi.lower() == 'true')
        if has_ac:
            queryset = queryset.filter(has_ac=has_ac.lower() == 'true')
        if has_attached_bathroom:
            queryset = queryset.filter(has_attached_bathroom=has_attached_bathroom.lower() == 'true')
        if parking_available:
            queryset = queryset.filter(parking_available=parking_available.lower() == 'true')
        if food_available:
            queryset = queryset.filter(food_available=food_available.lower() == 'true')
        if water_supply_available:
            queryset = queryset.filter(water_supply_available=water_supply_available.lower() == 'true')
        if waste_collection_available:
            queryset = queryset.filter(waste_collection_available=waste_collection_available.lower() == 'true')

        return queryset.distinct()

    def perform_create(self, serializer):
        serializer.save(landlord=self.request.user)

class RoomDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = RoomSerializer

    def get_permissions(self):
        if self.request.method == 'GET':
            return [AllowAny()]
        return [IsAuthenticated(), IsLandlord()]

    def get_queryset(self):
        user = self.request.user
        if user and user.is_authenticated:
            return Room.objects.filter(is_available=True) | Room.objects.filter(landlord=user)
        return Room.objects.filter(is_available=True)

    def perform_update(self, serializer):
        room = self.get_object()
        if room.landlord_id != self.request.user.id:
            raise PermissionDenied('You can only update your own rooms.')
        serializer.save()

    def perform_destroy(self, instance):
        if instance.landlord_id != self.request.user.id:
            raise PermissionDenied('You can only delete your own rooms.')
        instance.delete()

class MyRoomsView(generics.ListAPIView):
    permission_classes = [IsAuthenticated, IsLandlord]
    serializer_class = RoomSerializer
    def get_queryset(self):
        return Room.objects.filter(landlord=self.request.user)

class RoomAvailabilityView(APIView):
    permission_classes = [IsAuthenticated, IsLandlord]

    def patch(self, request, pk):
        room = get_object_or_404(Room, pk=pk, landlord=request.user)
        room.is_available = not room.is_available
        room.save(update_fields=['is_available'])
        return Response({'message': 'Room availability updated.', 'is_available': room.is_available}, status=status.HTTP_200_OK)


class RoomImageListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated, IsLandlord]
    serializer_class = RoomImageSerializer

    def get_queryset(self):
        return RoomImage.objects.filter(room_id=self.kwargs['room_id'])

    def perform_create(self, serializer):
        room = get_object_or_404(Room, pk=self.kwargs['room_id'], landlord=self.request.user)
        serializer.save(room=room)


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
