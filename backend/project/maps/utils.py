"""
utils.py
========
Helper utilities for the maps app.
"""

import math
from .graph_loader import get_node_coords


def snap_to_node(lat: float, lng: float) -> int:
    """
    Find the nearest road-graph node to the given GPS coordinates.

    Uses Euclidean distance on raw lat/lng degrees, which is a good
    enough approximation for city-scale distances (error < 0.1% within
    a single city).  For production use, Haversine could replace this.

    Parameters
    ----------
    lat : Latitude  (decimal degrees)
    lng : Longitude (decimal degrees)

    Returns
    -------
    Node ID (int) of the nearest graph node.
    """
    coords = get_node_coords()
    best_node = None
    best_dist = math.inf

    for node_id, (node_lat, node_lng) in coords.items():
        # Euclidean distance in degree-space
        d = math.sqrt((node_lat - lat) ** 2 + (node_lng - lng) ** 2)
        if d < best_dist:
            best_dist = d
            best_node = node_id

    return best_node


def haversine_metres(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    """
    Compute the great-circle distance (metres) between two GPS points.
    Used for straight-line distance estimates when no path is available.
    """
    R = 6_371_000  # Earth radius in metres
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lng2 - lng1)

    a = math.sin(dphi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2) ** 2
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
