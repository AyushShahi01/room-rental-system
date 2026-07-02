"""
test_maps.py
============
End-to-end test script for the maps API.

Usage:
    python test_maps.py --email <email> --password <password>
    python test_maps.py  # prompts for credentials

Tests:
    1. Auth — obtain JWT token
    2. GET /api/maps/rooms/           — room location list
    3. GET /api/maps/rooms/<id>/      — single room (if any exist)
    4. POST /api/maps/route/shortest/ — Bidirectional Dijkstra route
    5. POST /api/maps/route/shortest/ — Validation error case
"""

import sys
import json
import argparse
import urllib.request
import urllib.error

BASE = "http://127.0.0.1:8000"

# Two well-known Kathmandu coordinates for the route test
ORIGIN      = {"lat": 27.7172, "lng": 85.3240}   # Kathmandu Durbar Square area
DESTINATION = {"lat": 27.6914, "lng": 85.3420}   # Patan / Lalitpur area


def color(text, code):
    return f"\033[{code}m{text}\033[0m"

def ok(msg):    print(f"  [PASS] {msg}")
def fail(msg):  print(f"  [FAIL] {msg}")
def info(msg):  print(f"  [INFO] {msg}")
def header(msg): print(f"\n{'=' * 60}\n  {msg}\n{'=' * 60}")


def request(method, path, data=None, token=None):
    url = BASE + path
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"

    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(url, data=body, headers=headers, method=method)

    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            return resp.status, json.loads(resp.read())
    except urllib.error.HTTPError as e:
        try:
            return e.code, json.loads(e.read())
        except Exception:
            return e.code, {}
    except Exception as e:
        return None, str(e)


def get_token(email, password):
    header("Test 1 — Authentication")
    status, body = request("POST", "/api/auth/login/", {"email": email, "password": password})
    info(f"POST /api/auth/login/ → HTTP {status}")

    if status == 200 and "tokens" in body:
        ok(f"Token obtained (user: {email})")
        return body["tokens"]["access"]
    else:
        fail(f"Login failed: {body}")
        sys.exit(1)


def test_room_list(token):
    header("Test 2 — GET /api/maps/rooms/")
    status, body = request("GET", "/api/maps/rooms/", token=token)
    info(f"HTTP {status}")

    if status == 200:
        if isinstance(body, list):
            ok(f"Returned {len(body)} rooms with coordinates")
            if body:
                r = body[0]
                info(f"First room: id={r.get('id')} title='{r.get('title')}' "
                     f"lat={r.get('latitude')} lng={r.get('longitude')}")
                return r.get('id')
            else:
                info("No rooms have coordinates yet (set lat/lng in admin to populate)")
        else:
            ok(f"Response: {body}")
    else:
        fail(f"Unexpected status {status}: {body}")
    return None


def test_room_detail(token, room_id):
    if not room_id:
        info("Skipping room detail test — no rooms with coordinates")
        return
    header(f"Test 3 — GET /api/maps/rooms/{room_id}/")
    status, body = request("GET", f"/api/maps/rooms/{room_id}/", token=token)
    info(f"HTTP {status}")
    if status == 200:
        ok(f"Room {room_id}: lat={body.get('latitude')} lng={body.get('longitude')}")
    else:
        fail(f"Unexpected status {status}: {body}")


def test_shortest_route(token):
    header("Test 4 — POST /api/maps/route/shortest/ (valid route)")
    payload = {
        "origin_lat":      ORIGIN["lat"],
        "origin_lng":      ORIGIN["lng"],
        "destination_lat": DESTINATION["lat"],
        "destination_lng": DESTINATION["lng"],
    }
    info(f"Origin:      ({ORIGIN['lat']}, {ORIGIN['lng']})  — Kathmandu Durbar Square")
    info(f"Destination: ({DESTINATION['lat']}, {DESTINATION['lng']})  — Patan/Lalitpur")
    info("Waiting for Bidirectional Dijkstra... (may take a moment if graph is still loading)")

    status, body = request("POST", "/api/maps/route/shortest/", data=payload, token=token)
    info(f"HTTP {status}")

    if status == 200:
        path = body.get("path", [])
        dist = body.get("distance_meters", 0)
        algo = body.get("algorithm", "")
        ok(f"Route found!")
        ok(f"Algorithm:        {algo}")
        ok(f"Distance:         {dist:.1f} m  ({dist/1000:.2f} km)")
        ok(f"Path nodes:       {body.get('node_count')}")
        ok(f"Origin node:      {body.get('origin_node')}")
        ok(f"Destination node: {body.get('destination_node')}")
        if path:
            ok(f"First coord:  lat={path[0]['lat']:.6f}, lng={path[0]['lng']:.6f}")
            ok(f"Last coord:   lat={path[-1]['lat']:.6f}, lng={path[-1]['lng']:.6f}")
    elif status == 503:
        fail("Graph not loaded yet — server may still be downloading OSM data. Try again in 30s.")
        info(f"Response: {body}")
    elif status == 404:
        fail(f"No path found (disconnected nodes): {body}")
    else:
        fail(f"Unexpected status {status}: {body}")


def test_validation_error(token):
    header("Test 5 — Validation error (invalid coordinates)")
    payload = {
        "origin_lat":      999,   # invalid — out of range
        "origin_lng":      85.32,
        "destination_lat": 27.69,
        "destination_lng": 85.34,
    }
    status, body = request("POST", "/api/maps/route/shortest/", data=payload, token=token)
    info(f"HTTP {status}")
    if status == 400:
        ok(f"Correctly rejected invalid input: {body}")
    else:
        fail(f"Expected 400, got {status}: {body}")


def main():
    parser = argparse.ArgumentParser(description="Test the maps API")
    parser.add_argument("--email",    default=None)
    parser.add_argument("--password", default=None)
    args = parser.parse_args()

    email    = args.email    or input("Email:    ").strip()
    password = args.password or input("Password: ").strip()

    print(f"\nMaps API Test Suite -- {BASE}")

    token   = get_token(email, password)
    room_id = test_room_list(token)
    test_room_detail(token, room_id)
    test_shortest_route(token)
    test_validation_error(token)

    print(f"\n{color('Done!', '32')}\n")


if __name__ == "__main__":
    main()
