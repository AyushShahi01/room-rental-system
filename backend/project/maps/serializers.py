"""
serializers.py
==============
Request / Response serializers for the maps app.
"""

from rest_framework import serializers
from rooms.models import Room


# ── Room location serializer ──────────────────────────────────────────────────

class RoomLocationSerializer(serializers.ModelSerializer):
    """Lightweight serializer returning only the fields needed for map markers."""

    class Meta:
        model = Room
        fields = [
            'id',
            'title',
            'price',
            'province',
            'state',
            'ward_number',
            'is_available',
            'latitude',
            'longitude',
        ]


# ── Route request serializer ──────────────────────────────────────────────────

class RouteRequestSerializer(serializers.Serializer):
    """Validates the body of POST /api/maps/route/shortest/"""

    origin_lat = serializers.FloatField(
        help_text="Latitude of the user's current position"
    )
    origin_lng = serializers.FloatField(
        help_text="Longitude of the user's current position"
    )
    destination_lat = serializers.FloatField(
        help_text="Latitude of the destination (e.g. a room)"
    )
    destination_lng = serializers.FloatField(
        help_text="Longitude of the destination"
    )

    def validate_origin_lat(self, value):
        if not (-90 <= value <= 90):
            raise serializers.ValidationError("Latitude must be between -90 and 90.")
        return value

    def validate_origin_lng(self, value):
        if not (-180 <= value <= 180):
            raise serializers.ValidationError("Longitude must be between -180 and 180.")
        return value

    def validate_destination_lat(self, value):
        if not (-90 <= value <= 90):
            raise serializers.ValidationError("Latitude must be between -90 and 90.")
        return value

    def validate_destination_lng(self, value):
        if not (-180 <= value <= 180):
            raise serializers.ValidationError("Longitude must be between -180 and 180.")
        return value


# ── Coordinate point (used in the route response) ────────────────────────────

class CoordinateSerializer(serializers.Serializer):
    lat = serializers.FloatField()
    lng = serializers.FloatField()


# ── Route response serializer ─────────────────────────────────────────────────

class RouteResponseSerializer(serializers.Serializer):
    """Shape of the successful route response."""

    path = CoordinateSerializer(many=True)
    distance_meters = serializers.FloatField()
    node_count = serializers.IntegerField()
    algorithm = serializers.CharField()
    origin_node = serializers.IntegerField()
    destination_node = serializers.IntegerField()
