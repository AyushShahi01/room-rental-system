"""
graph_loader.py
===============
Handles downloading, caching, and serving the OpenStreetMap road network graph.

The graph is fetched once at Django startup (via AppConfig.ready()) and held
in module-level memory. Subsequent API calls reuse the cached graph — no
repeated network requests.

Graph type: networkx.MultiDiGraph (directed, respects one-way streets)
Edge weight used: 'length' (metres) for shortest distance.
"""

import logging
import os
import pickle
from pathlib import Path

import networkx as nx
import osmnx as ox
from django.conf import settings

logger = logging.getLogger(__name__)

# ── Module-level graph cache ──────────────────────────────────────────────────
_graph: nx.MultiDiGraph | None = None

# Adjacency dict cache:  {node_id: {neighbour_id: distance_metres, ...}, ...}
# Built from the MultiDiGraph for O(1) edge lookups during Dijkstra.
_adj: dict | None = None

# Coordinate lookup:  {node_id: (lat, lng)}
_node_coords: dict | None = None

# ── Pickle cache path (avoids re-downloading on every restart) ────────────────
_CACHE_DIR = Path(settings.BASE_DIR) / '.osm_cache'
_CACHE_FILE = _CACHE_DIR / 'road_graph.pkl'


def _download_graph(city: str) -> nx.MultiDiGraph:
    """Download the OSM driving graph for *city* and return it."""
    logger.info(f"[Maps] Downloading OSM road graph for '{city}' ...")
    # network_type='drive' → only driveable roads (excludes footpaths, etc.)
    G = ox.graph_from_place(city, network_type='drive')
    logger.info(f"[Maps] Downloaded graph: {len(G.nodes)} nodes, {len(G.edges)} edges")
    return G


def _build_adj(G: nx.MultiDiGraph) -> tuple[dict, dict]:
    """
    Build a lightweight adjacency dict and coordinate lookup from the graph.

    adjacency format:
        { node_id: { neighbour_id: min_edge_length_metres, ... }, ... }

    coords format:
        { node_id: (lat, lng) }

    Using min edge length when parallel edges exist (MultiDiGraph can have
    multiple edges between the same pair of nodes — e.g. different lanes).
    """
    adj: dict = {}
    coords: dict = {}

    for node, data in G.nodes(data=True):
        coords[node] = (data['y'], data['x'])  # osmnx stores lat=y, lng=x
        adj[node] = {}

    for u, v, data in G.edges(data=True):
        length = data.get('length', 1.0)  # metres; default 1 if missing
        # Keep shortest parallel edge
        if v not in adj[u] or length < adj[u][v]:
            adj[u][v] = length

    return adj, coords


def load_graph() -> None:
    """
    Load (or download) the OSM road graph and populate module-level caches.
    Called once from MapsConfig.ready().
    """
    global _graph, _adj, _node_coords

    if _graph is not None:
        return  # already loaded

    city = getattr(settings, 'OSM_CITY', 'Kathmandu, Nepal')

    # ── Try loading from pickle cache first ───────────────────────────────────
    if _CACHE_FILE.exists():
        try:
            logger.info(f"[Maps] Loading OSM graph from cache: {_CACHE_FILE}")
            with open(_CACHE_FILE, 'rb') as f:
                _graph = pickle.load(f)
            logger.info(f"[Maps] Loaded from cache: {len(_graph.nodes)} nodes")
        except Exception as e:
            logger.warning(f"[Maps] Cache load failed ({e}), re-downloading ...")
            _graph = None

    # ── Download and cache if needed ──────────────────────────────────────────
    if _graph is None:
        _graph = _download_graph(city)
        try:
            _CACHE_DIR.mkdir(parents=True, exist_ok=True)
            with open(_CACHE_FILE, 'wb') as f:
                pickle.dump(_graph, f)
            logger.info(f"[Maps] Graph cached to {_CACHE_FILE}")
        except Exception as e:
            logger.warning(f"[Maps] Failed to cache graph: {e}")

    # ── Build adjacency + coordinate lookups ─────────────────────────────────
    _adj, _node_coords = _build_adj(_graph)
    logger.info("[Maps] Graph ready. Adjacency dict built.")


def get_graph() -> nx.MultiDiGraph:
    """Return the cached graph (raises if not loaded yet)."""
    if _graph is None:
        raise RuntimeError("OSM graph not loaded. Call load_graph() first.")
    return _graph


def get_adj() -> dict:
    """Return the cached adjacency dict."""
    if _adj is None:
        raise RuntimeError("Adjacency dict not built. Call load_graph() first.")
    return _adj


def get_node_coords() -> dict:
    """Return the cached {node_id: (lat, lng)} lookup."""
    if _node_coords is None:
        raise RuntimeError("Node coords not built. Call load_graph() first.")
    return _node_coords
