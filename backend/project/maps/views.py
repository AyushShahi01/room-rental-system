"""
views.py
========
API views for the maps app.

Endpoints
---------
GET  /api/maps/rooms/              → All rooms that have coordinates
GET  /api/maps/rooms/<pk>/         → Single room with coordinates
POST /api/maps/route/shortest/     → Bidirectional Dijkstra route
"""

import logging

from drf_spectacular.utils import extend_schema, OpenApiResponse
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from rooms.models import Room
from .dijkstra import bidirectional_dijkstra, path_to_coordinates
from .graph_loader import get_adj, get_node_coords
from .serializers import (
    RouteRequestSerializer,
    RouteResponseSerializer,
    RoomLocationSerializer,
)
from .utils import snap_to_node

logger = logging.getLogger(__name__)


# ── Room Location Views ────────────────────────────────────────────────────────

class RoomLocationListView(APIView):
    """
    GET /api/maps/rooms/

    Returns all rooms that have latitude and longitude set.
    Used by the Flutter app to place markers on the map.
    """

    permission_classes = [IsAuthenticated]

    @extend_schema(
        summary="List rooms with map coordinates",
        description=(
            "Returns all available rooms that have GPS coordinates (latitude/longitude) set. "
            "Use this to populate map markers in the Flutter app."
        ),
        responses={200: RoomLocationSerializer(many=True)},
        tags=["Maps"],
    )
    def get(self, request):
        rooms = Room.objects.filter(
            latitude__isnull=False,
            longitude__isnull=False,
        ).select_related('landlord')

        serializer = RoomLocationSerializer(rooms, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


class RoomLocationDetailView(APIView):
    """
    GET /api/maps/rooms/<pk>/

    Returns a single room's location data.
    """

    permission_classes = [IsAuthenticated]

    @extend_schema(
        summary="Get single room map coordinates",
        responses={
            200: RoomLocationSerializer,
            404: OpenApiResponse(description="Room not found or has no coordinates"),
        },
        tags=["Maps"],
    )
    def get(self, request, pk: int):
        try:
            room = Room.objects.get(pk=pk, latitude__isnull=False, longitude__isnull=False)
        except Room.DoesNotExist:
            return Response(
                {"detail": "Room not found or does not have map coordinates."},
                status=status.HTTP_404_NOT_FOUND,
            )

        serializer = RoomLocationSerializer(room)
        return Response(serializer.data, status=status.HTTP_200_OK)


# ── Route View ─────────────────────────────────────────────────────────────────

class ShortestRouteView(APIView):
    """
    POST /api/maps/route/shortest/

    Accepts an origin and destination GPS coordinate pair.
    Snaps both to the nearest OSM road-graph nodes, then runs
    Bidirectional Dijkstra to find the shortest driving route.

    Returns the ordered list of coordinates forming the path,
    the total distance in metres, and metadata about the algorithm.
    """

    permission_classes = [IsAuthenticated]

    @extend_schema(
        summary="Compute shortest path (Bidirectional Dijkstra)",
        description=(
            "Runs a custom Bidirectional Dijkstra algorithm on the OpenStreetMap road network "
            "to find the shortest driving path between two GPS coordinates. "
            "The returned `path` array can be used directly as a polyline on flutter_map."
        ),
        request=RouteRequestSerializer,
        responses={
            200: RouteResponseSerializer,
            400: OpenApiResponse(description="Invalid input coordinates"),
            503: OpenApiResponse(description="Road graph not loaded yet"),
        },
        tags=["Maps"],
    )
    def post(self, request):
        # ── Validate input ────────────────────────────────────────────────────
        serializer = RouteRequestSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        data = serializer.validated_data
        origin_lat = data['origin_lat']
        origin_lng = data['origin_lng']
        dest_lat = data['destination_lat']
        dest_lng = data['destination_lng']

        # ── Check graph is loaded ─────────────────────────────────────────────
        try:
            adj = get_adj()
            node_coords = get_node_coords()
        except RuntimeError as e:
            logger.error(f"[Maps] Graph not ready: {e}")
            return Response(
                {"detail": "Road graph is not loaded yet. Please try again in a moment."},
                status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )

        # ── Snap GPS coordinates to nearest road nodes ────────────────────────
        source_node = snap_to_node(origin_lat, origin_lng)
        target_node = snap_to_node(dest_lat, dest_lng)

        logger.info(
            f"[Maps] Route request: ({origin_lat},{origin_lng}) → ({dest_lat},{dest_lng}) "
            f"| nodes: {source_node} → {target_node}"
        )

        # ── Run Bidirectional Dijkstra ─────────────────────────────────────────
        result = bidirectional_dijkstra(adj, node_coords, source_node, target_node)

        if result is None:
            return Response(
                {
                    "detail": (
                        "No path found between the given coordinates. "
                        "The points may be in disconnected road segments."
                    )
                },
                status=status.HTTP_404_NOT_FOUND,
            )

        path_nodes, total_distance = result
        path_coords = path_to_coordinates(path_nodes, node_coords)

        logger.info(
            f"[Maps] Route found: {len(path_nodes)} nodes, {total_distance:.1f} m"
        )

        return Response(
            {
                "path": path_coords,
                "distance_meters": round(total_distance, 2),
                "node_count": len(path_nodes),
                "algorithm": "bidirectional_dijkstra",
                "origin_node": source_node,
                "destination_node": target_node,
            },
            status=status.HTTP_200_OK,
        )
