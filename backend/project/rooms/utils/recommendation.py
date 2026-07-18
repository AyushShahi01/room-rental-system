"""Cosine-similarity room recommendations.

The recommendation engine uses an active-only feature vector:
- booleans are converted to 0/1 and weighted according to feature importance
- price is evaluated independently using a directional budget penalty
- gender matching is enforced as a hard filter prior to similarity scoring

Location is scored independently (via coordinates or text) and combined as a weighted score.
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from decimal import Decimal
from typing import Any

from rooms.models import Room


BOOLEAN_FEATURES = (
    "furnished_status",
    "has_wifi",
    "has_ac",
    "has_attached_bathroom",
    "parking_available",
    "food_available",
    "water_supply_available",
    "waste_collection_available",
)

# Feature weights to prioritize crucial amenities in weighted cosine similarity
FEATURE_WEIGHTS = {
    "furnished_status": 1.0,
    "has_wifi": 2.0,                  # wifi is highly desired
    "has_ac": 1.5,                    # ac is moderately desired
    "has_attached_bathroom": 2.0,     # attached bathroom is highly desired
    "parking_available": 1.0,
    "food_available": 1.5,
    "water_supply_available": 1.5,
    "waste_collection_available": 1.0,
}


@dataclass(frozen=True)
class RecommendationScore:
    """Structured score returned by the recommendation engine."""

    room: Room
    cosine_similarity: float
    location_score: float
    combined_score: float


def _clean_text(value: Any) -> str:
    return str(value or "").strip().lower()


def _to_bool(value: Any) -> int:
    return 1 if bool(value) else 0


def cosine_similarity(
    vector_a: list[float],
    vector_b: list[float],
    weights: list[float] | None = None,
) -> float:
    """Compute weighted cosine similarity from scratch.

    Returns 0.0 when either vector is empty or has zero magnitude.
    """
    if len(vector_a) != len(vector_b) or not vector_a:
        return 0.0

    if weights is None:
        weights = [1.0] * len(vector_a)

    dot_product = sum(w * left * right for w, left, right in zip(weights, vector_a, vector_b))
    magnitude_a = sum(w * value * value for w, value in zip(weights, vector_a)) ** 0.5
    magnitude_b = sum(w * value * value for w, value in zip(weights, vector_b)) ** 0.5

    if magnitude_a == 0 or magnitude_b == 0:
        return 0.0

    return dot_product / (magnitude_a * magnitude_b)


def haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculate the great circle distance between two points on the earth in km."""
    R = 6371.0  # Earth radius in kilometers

    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)

    a = (
        math.sin(delta_phi / 2.0) ** 2
        + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2.0) ** 2
    )
    c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))

    return R * c


def _has_location_preferences(preferences: dict[str, Any]) -> bool:
    return (
        bool(_clean_text(preferences.get("province")))
        or bool(_clean_text(preferences.get("state")))
        or (preferences.get("latitude") is not None and preferences.get("longitude") is not None)
    )


def location_score(room: Room, preferences: dict[str, Any]) -> float:
    """Score location based on physical distance or fallback to state/province matches.

    If latitude/longitude coordinates are available in both preferences and room,
    distance is calculated using the Haversine formula and scored between 0.0 and 1.0.
    Otherwise, falls back to text-based province/state matches.
    """
    pref_lat = preferences.get("latitude")
    pref_lon = preferences.get("longitude")

    if (
        pref_lat is not None
        and pref_lon is not None
        and room.latitude is not None
        and room.longitude is not None
    ):
        try:
            dist = haversine_distance(
                float(pref_lat),
                float(pref_lon),
                float(room.latitude),
                float(room.longitude),
            )
            # Linear decay: 1.0 at 0km, decaying to 0.0 at 10km
            return max(0.0, 1.0 - (dist / 10.0))
        except (ValueError, TypeError):
            pass

    # Fallback to string matching on province and state
    weighted_matches = 0.0
    active_fields = 0

    preferred_province = _clean_text(preferences.get("province"))
    preferred_state = _clean_text(preferences.get("state"))

    if preferred_province:
        active_fields += 1
        weighted_matches += 1.0 if preferred_province == _clean_text(room.province) else 0.0

    if preferred_state:
        active_fields += 1
        weighted_matches += 1.0 if preferred_state == _clean_text(room.state) else 0.0

    if active_fields == 0:
        return 0.0

    return weighted_matches / active_fields


def price_score(room: Room, preferred_price: float | Decimal | None) -> float:
    """Calculate price score with a directional penalty.

    If room price is within budget, returns 1.0.
    If room price exceeds preferred price, returns an exponentially decaying score.
    """
    if preferred_price is None or room.price is None:
        return 1.0

    try:
        r_price = float(room.price)
        p_price = float(preferred_price)
    except (ValueError, TypeError):
        return 1.0

    if p_price <= 0:
        return 1.0

    if r_price <= p_price:
        return 1.0

    # Exponential decay when exceeding budget
    price_diff_ratio = (r_price - p_price) / p_price
    return math.exp(-price_diff_ratio)


def _build_feature_vector(
    room: Room,
    preferences: dict[str, Any],
) -> tuple[list[float], list[float], list[float]]:
    """Create aligned room and preference vectors and matching weights.

    Uses only active boolean features. Price and gender are handled separately.
    """
    room_vector: list[float] = []
    preference_vector: list[float] = []
    weights: list[float] = []

    for feature_name in BOOLEAN_FEATURES:
        if feature_name in preferences and preferences.get(feature_name) is not None:
            room_vector.append(_to_bool(getattr(room, feature_name)))
            preference_vector.append(_to_bool(preferences.get(feature_name)))
            weights.append(FEATURE_WEIGHTS.get(feature_name, 1.0))

    return room_vector, preference_vector, weights


def recommend_rooms(
    rooms: list[Room] | Any,
    preferences: dict[str, Any],
) -> list[RecommendationScore]:
    """Rank rooms using weighted cosine similarity, location distance, and price scoring.

    Gender matches are handled as hard constraints before ranking.
    """
    active_rooms = list(rooms)
    if not active_rooms:
        return []

    # Hard constraints: gender preference filtering
    preferred_gender = _clean_text(preferences.get("gender_preference"))
    if preferred_gender == Room.GENDER_PREFERENCE_MALE:
        active_rooms = [r for r in active_rooms if r.gender_preference != Room.GENDER_PREFERENCE_FEMALE]
    elif preferred_gender == Room.GENDER_PREFERENCE_FEMALE:
        active_rooms = [r for r in active_rooms if r.gender_preference != Room.GENDER_PREFERENCE_MALE]

    results: list[RecommendationScore] = []
    location_active = _has_location_preferences(preferences)
    preferred_price = preferences.get("preferred_price")
    price_active = preferred_price is not None

    for room in active_rooms:
        room_vector, preference_vector, weights = _build_feature_vector(room, preferences)
        cosine_score = cosine_similarity(room_vector, preference_vector, weights)

        current_price_score = price_score(room, preferred_price)
        current_location_score = location_score(room, preferences)

        # Dynamic combined score weights depending on active components
        if price_active and location_active:
            combined_score = (
                (0.50 * cosine_score)
                + (0.25 * current_price_score)
                + (0.25 * current_location_score)
            )
        elif price_active:
            combined_score = (0.70 * cosine_score) + (0.30 * current_price_score)
        elif location_active:
            combined_score = (0.75 * cosine_score) + (0.25 * current_location_score)
        else:
            combined_score = cosine_score

        results.append(
            RecommendationScore(
                room=room,
                cosine_similarity=round(cosine_score, 4),
                location_score=round(current_location_score, 4),
                combined_score=round(combined_score, 4),
            )
        )

    results.sort(key=lambda item: (item.combined_score, item.cosine_similarity), reverse=True)
    return results
