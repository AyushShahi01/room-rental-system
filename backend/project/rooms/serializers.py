from rest_framework import serializers
from .models import Room, RoomImage

MAX_ROOM_IMAGES = 10


class RoomImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = RoomImage
        fields = ('id', 'room', 'image', 'created_at')
        read_only_fields = ('created_at', 'room')


class RoomImageUploadSerializer(serializers.Serializer):
    """Accepts 1-10 images in a single request."""
    images = serializers.ListField(
        child=serializers.ImageField(),
        min_length=1,
        max_length=MAX_ROOM_IMAGES,
    )

    def validate_images(self, images):
        room = self.context.get('room')
        if room is not None:
            existing = room.images.count()
            if existing + len(images) > MAX_ROOM_IMAGES:
                remaining = MAX_ROOM_IMAGES - existing
                raise serializers.ValidationError(
                    f'A room can have at most {MAX_ROOM_IMAGES} images. '
                    f'This room already has {existing}; you can add at most {remaining} more.'
                )
        return images



class RoomSerializer(serializers.ModelSerializer):
    images = RoomImageSerializer(many=True, read_only=True)

    class Meta:
        model = Room
        fields = '__all__'
        read_only_fields = ('landlord', 'created_at', 'updated_at')

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        from users.serializers import UserSerializer
        representation['landlord'] = UserSerializer(instance.landlord, context=self.context).data
        return representation

    def validate_price(self, value):
        if value <= 0:
            raise serializers.ValidationError('Price must be greater than zero.')
        return value

    def validate_ward_number(self, value):
        if value <= 0:
            raise serializers.ValidationError('Ward number must be a positive integer.')
        return value


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
