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
from .utils import snap_to_node, haversine_metres

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
        from django.core.cache import cache
        cache_key = "room_locations_list"
        cached_data = cache.get(cache_key)
        if cached_data is not None:
            logger.info("[Maps] Room locations cache hit")
            return Response(cached_data, status=status.HTTP_200_OK)

        rooms = Room.objects.filter(
            latitude__isnull=False,
            longitude__isnull=False,
            is_available=True,
        ).select_related('landlord')

        serializer = RoomLocationSerializer(rooms, many=True)
        data = serializer.data
        cache.set(cache_key, data, timeout=3600)  # Cache for 1 hour
        return Response(data, status=status.HTTP_200_OK)


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

        # ── Check cache first ──────────────────────────────────────────────────
        from django.core.cache import cache
        cache_key = f"route:{round(float(origin_lat), 5)}:{round(float(origin_lng), 5)}:{round(float(dest_lat), 5)}:{round(float(dest_lng), 5)}"
        cached_data = cache.get(cache_key)
        if cached_data is not None:
            logger.info(f"[Maps] Route cache hit: {cache_key}")
            return Response(cached_data, status=status.HTTP_200_OK)

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

        # ── Attempt OSRM Global Routing First (No API Key Required) ───────────
        import requests
        try:
            osrm_url = (
                f"http://router.project-osrm.org/route/v1/driving/"
                f"{origin_lng},{origin_lat};{dest_lng},{dest_lat}"
                f"?geometries=geojson&overview=full"
            )
            response = requests.get(osrm_url, timeout=4)
            if response.status_code == 200:
                res_data = response.json()
                if res_data.get("code") == "Ok" and res_data.get("routes"):
                    route = res_data["routes"][0]
                    coordinates = route["geometry"]["coordinates"]
                    distance_meters = float(route["distance"])
                    
                    # Convert GeoJSON [lng, lat] to our format [{"lat": y, "lng": x}, ...]
                    path_coords = [{"lat": coord[1], "lng": coord[0]} for coord in coordinates]
                    
                    logger.info(
                        f"[Maps] Route successfully resolved via OSRM: {distance_meters:.1f} m, {len(path_coords)} points"
                    )
                    route_data = {
                        "path": path_coords,
                        "distance_meters": round(distance_meters, 2),
                        "node_count": len(path_coords),
                        "algorithm": "osrm_global_routing",
                        "origin_node": 0,
                        "destination_node": 0,
                    }
                    cache.set(cache_key, route_data, timeout=86400)  # Cache for 24 hours
                    return Response(route_data, status=status.HTTP_200_OK)
        except Exception as e:
            logger.warning(f"[Maps] OSRM routing failed or timed out: {e}. Falling back to local Dijkstra...")

        # ── Offline Fallback: Local Bidirectional Dijkstra (Kathmandu only) ─────
        source_node = snap_to_node(origin_lat, origin_lng)
        target_node = snap_to_node(dest_lat, dest_lng)

        source_lat, source_lng = node_coords[source_node]
        target_lat, target_lng = node_coords[target_node]

        dist_to_source = haversine_metres(origin_lat, origin_lng, source_lat, source_lng)
        dist_to_target = haversine_metres(dest_lat, dest_lng, target_lat, target_lng)

        # Threshold distance to switch to straight-line fallback (e.g. 10.0 km)
        MAX_SNAP_DISTANCE = 10000.0

        if dist_to_source > MAX_SNAP_DISTANCE or dist_to_target > MAX_SNAP_DISTANCE:
            # Selected point is too far from Kathmandu road graph (fallback straight line)
            straight_distance = haversine_metres(origin_lat, origin_lng, dest_lat, dest_lng)
            path_coords = [
                {"lat": origin_lat, "lng": origin_lng},
                {"lat": dest_lat, "lng": dest_lng}
            ]
            route_data = {
                "path": path_coords,
                "distance_meters": round(straight_distance, 2),
                "node_count": 2,
                "algorithm": "straight_line_fallback",
                "origin_node": source_node,
                "destination_node": target_node,
            }
            cache.set(cache_key, route_data, timeout=86400)  # Cache for 24 hours
            return Response(route_data, status=status.HTTP_200_OK)

        logger.info(
            f"[Maps] Running local Dijkstra: ({origin_lat},{origin_lng}) → ({dest_lat},{dest_lng}) "
            f"| nodes: {source_node} → {target_node}"
        )

        result = bidirectional_dijkstra(adj, node_coords, source_node, target_node)

        if result is None:
            # Dijkstra failed inside the graph, fallback to straight line
            straight_distance = haversine_metres(origin_lat, origin_lng, dest_lat, dest_lng)
            path_coords = [
                {"lat": origin_lat, "lng": origin_lng},
                {"lat": dest_lat, "lng": dest_lng}
            ]
            route_data = {
                "path": path_coords,
                "distance_meters": round(straight_distance, 2),
                "node_count": 2,
                "algorithm": "straight_line_fallback",
                "origin_node": source_node,
                "destination_node": target_node,
            }
            cache.set(cache_key, route_data, timeout=86400)  # Cache for 24 hours
            return Response(route_data, status=status.HTTP_200_OK)

        path_nodes, total_distance = result
        path_coords = path_to_coordinates(path_nodes, node_coords)

        # Prepend actual starting position and append actual destination to remove visual gaps
        path_coords.insert(0, {"lat": origin_lat, "lng": origin_lng})
        path_coords.append({"lat": dest_lat, "lng": dest_lng})

        # Add the off-road access segment distances to the total path distance
        total_distance += dist_to_source + dist_to_target

        logger.info(
            f"[Maps] Route found via local Dijkstra: {len(path_nodes)} nodes (plus start/end pins), {total_distance:.1f} m"
        )

        route_data = {
            "path": path_coords,
            "distance_meters": round(total_distance, 2),
            "node_count": len(path_nodes) + 2,
            "algorithm": "bidirectional_dijkstra",
            "origin_node": source_node,
            "destination_node": target_node,
        }
        cache.set(cache_key, route_data, timeout=86400)  # Cache for 24 hours
        return Response(route_data, status=status.HTTP_200_OK)
