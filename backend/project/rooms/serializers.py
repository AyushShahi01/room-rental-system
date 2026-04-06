from rest_framework import serializers
from .models import Room, RoomImage


class RoomImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = RoomImage
        fields = ('id', 'room', 'image', 'created_at')
        read_only_fields = ('created_at',)


class RoomSerializer(serializers.ModelSerializer):
    images = RoomImageSerializer(many=True, read_only=True)

    class Meta:
        model = Room
        fields = '__all__'


class RoomRecommendationRequestSerializer(serializers.Serializer):
    """Example preference payload:

    {
        "preferred_price": "500.00",
        "province": "Bagmati",
        "state": "Kathmandu",
        "furnished_status": true,
        "has_wifi": true,
        "gender_preference": "male",
        "limit": 10
    }
    """

    preferred_price = serializers.DecimalField(max_digits=10, decimal_places=2, required=False, allow_null=True)
    province = serializers.CharField(required=False, allow_blank=True, allow_null=True)
    state = serializers.CharField(required=False, allow_blank=True, allow_null=True)
    furnished_status = serializers.BooleanField(required=False)
    has_wifi = serializers.BooleanField(required=False)
    has_ac = serializers.BooleanField(required=False)
    has_attached_bathroom = serializers.BooleanField(required=False)
    parking_available = serializers.BooleanField(required=False)
    food_available = serializers.BooleanField(required=False)
    water_supply_available = serializers.BooleanField(required=False)
    waste_collection_available = serializers.BooleanField(required=False)
    gender_preference = serializers.ChoiceField(
        choices=Room.GENDER_PREFERENCE_CHOICES,
        required=False,
        allow_null=True,
    )
    limit = serializers.IntegerField(required=False, default=10, min_value=1, max_value=50)


class RecommendedRoomSerializer(serializers.Serializer):
    room = RoomSerializer()
    cosine_similarity = serializers.FloatField()
    location_score = serializers.FloatField()
    combined_score = serializers.FloatField()


class RoomRecommendationResponseSerializer(serializers.Serializer):
    count = serializers.IntegerField()
    results = RecommendedRoomSerializer(many=True)
