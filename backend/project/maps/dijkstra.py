"""
dijkstra.py
===========
Bidirectional Dijkstra shortest-path algorithm.

Standard Dijkstra explores the full graph outward from one source node.
Bidirectional Dijkstra runs TWO simultaneous priority-queue searches:
  • Forward search  — expands from the origin
  • Backward search — expands from the destination (on the reversed graph)

When a node has been *settled* (popped from the queue) by BOTH searches,
a candidate path through that node is recorded.  The algorithm terminates
when the sum of the two frontier distances exceeds the best candidate found
so far — guaranteeing the optimal path has been found.

Complexity: roughly O((E/2) · log V) vs O(E · log V) for standard Dijkstra.
"""

import heapq
import math
from typing import Optional


def bidirectional_dijkstra(
    adj: dict,          # Forward adjacency:  {node: {neighbour: dist}}
    coords: dict,       # {node: (lat, lng)}
    source: int,
    target: int,
) -> Optional[tuple[list[int], float]]:
    """
    Run Bidirectional Dijkstra between *source* and *target*.

    Parameters
    ----------
    adj    : Forward adjacency dict  (built by graph_loader._build_adj)
    coords : Node coordinate lookup  {node_id: (lat, lng)}
    source : Starting node ID
    target : Destination node ID

    Returns
    -------
    (path, total_distance)
        path             — ordered list of node IDs from source to target
        total_distance   — total route length in metres
    None if no path exists.
    """
    if source == target:
        lat, lng = coords[source]
        return [source], 0.0

    # ── Build reverse adjacency for the backward search ─────────────────────
    # We only build the reverse edges we actually need lazily — but for
    # simplicity (and correctness) we build the full reverse adj here.
    # For city-scale graphs (~50 k nodes) this is fast enough.
    rev_adj: dict = {n: {} for n in adj}
    for u, neighbours in adj.items():
        for v, dist in neighbours.items():
            if u not in rev_adj[v]:
                rev_adj[v][u] = dist
            else:
                rev_adj[v][u] = min(rev_adj[v][u], dist)

    # ── Priority queues: (distance, node) ────────────────────────────────────
    fwd_heap: list = [(0.0, source)]
    bwd_heap: list = [(0.0, target)]

    # Best-known distance from source / target to each node
    fwd_dist: dict = {source: 0.0}
    bwd_dist: dict = {target: 0.0}

    # Parent maps for path reconstruction
    fwd_prev: dict = {source: None}
    bwd_prev: dict = {target: None}

    # Settled sets (nodes whose shortest distance is finalised)
    fwd_settled: set = set()
    bwd_settled: set = set()

    # Best complete-path cost seen so far and its meeting node
    best_cost: float = math.inf
    meeting_node: Optional[int] = None

    def _relax_fwd(node: int, cost: float) -> None:
        nonlocal best_cost, meeting_node
        for neighbour, edge_len in adj.get(node, {}).items():
            new_cost = cost + edge_len
            if new_cost < fwd_dist.get(neighbour, math.inf):
                fwd_dist[neighbour] = new_cost
                fwd_prev[neighbour] = node
                heapq.heappush(fwd_heap, (new_cost, neighbour))
                # Check if backward search already reached this node
                if neighbour in bwd_dist:
                    total = new_cost + bwd_dist[neighbour]
                    if total < best_cost:
                        best_cost = total
                        meeting_node = neighbour

    def _relax_bwd(node: int, cost: float) -> None:
        nonlocal best_cost, meeting_node
        for neighbour, edge_len in rev_adj.get(node, {}).items():
            new_cost = cost + edge_len
            if new_cost < bwd_dist.get(neighbour, math.inf):
                bwd_dist[neighbour] = new_cost
                bwd_prev[neighbour] = node
                heapq.heappush(bwd_heap, (new_cost, neighbour))
                # Check if forward search already reached this node
                if neighbour in fwd_dist:
                    total = fwd_dist[neighbour] + new_cost
                    if total < best_cost:
                        best_cost = total
                        meeting_node = neighbour

    # ── Main loop ─────────────────────────────────────────────────────────────
    while fwd_heap or bwd_heap:
        # Termination condition:
        # The minimum frontier costs of both searches together exceed best_cost.
        fwd_min = fwd_heap[0][0] if fwd_heap else math.inf
        bwd_min = bwd_heap[0][0] if bwd_heap else math.inf

        if fwd_min + bwd_min >= best_cost:
            break  # Optimal path confirmed — no better path can exist

        # Always expand the search with the smaller frontier distance
        if fwd_min <= bwd_min:
            cost, node = heapq.heappop(fwd_heap)
            if node in fwd_settled:
                continue
            fwd_settled.add(node)
            _relax_fwd(node, cost)
        else:
            cost, node = heapq.heappop(bwd_heap)
            if node in bwd_settled:
                continue
            bwd_settled.add(node)
            _relax_bwd(node, cost)

    if meeting_node is None:
        return None  # No path found

    # ── Reconstruct path ──────────────────────────────────────────────────────
    # Forward segment: source → meeting_node
    fwd_path: list = []
    node = meeting_node
    while node is not None:
        fwd_path.append(node)
        node = fwd_prev.get(node)
    fwd_path.reverse()

    # Backward segment: meeting_node → target (skip meeting_node to avoid dup)
    bwd_path: list = []
    node = bwd_prev.get(meeting_node)
    while node is not None:
        bwd_path.append(node)
        node = bwd_prev.get(node)

    full_path = fwd_path + bwd_path
    return full_path, best_cost


def path_to_coordinates(path: list[int], coords: dict) -> list[dict]:
    """
    Convert a list of node IDs into a list of {lat, lng} dicts.

    Parameters
    ----------
    path   : Ordered list of node IDs returned by bidirectional_dijkstra
    coords : {node_id: (lat, lng)} lookup from graph_loader

    Returns
    -------
    [{"lat": float, "lng": float}, ...]
    """
    return [
        {"lat": float(coords[node][0]), "lng": float(coords[node][1])}
        for node in path
        if node in coords
    ]
