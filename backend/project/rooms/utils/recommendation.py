"""Cosine-similarity room recommendations.

The recommendation engine uses an active-only feature vector:
- price is min-max normalized into the 0-1 range
- booleans are converted to 0/1
- gender is one-hot encoded only when both sides specify male/female

Location is intentionally kept separate and is combined as a weighted score.
"""

from __future__ import annotations

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

GENDER_FEATURES = (Room.GENDER_PREFERENCE_MALE, Room.GENDER_PREFERENCE_FEMALE)


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


def _normalize_price(value: Decimal | float | int | None, min_price: float, max_price: float) -> float:
    if value is None:
        return 0.0

    numeric_value = float(value)
    if max_price <= min_price:
        return 0.5

    normalized = (numeric_value - min_price) / (max_price - min_price)
    return max(0.0, min(1.0, normalized))


def cosine_similarity(vector_a: list[float], vector_b: list[float]) -> float:
    """Compute cosine similarity from scratch.

    Returns 0.0 when either vector is empty or has zero magnitude.
    """

    if len(vector_a) != len(vector_b) or not vector_a:
        return 0.0

    dot_product = sum(left * right for left, right in zip(vector_a, vector_b))
    magnitude_a = sum(value * value for value in vector_a) ** 0.5
    magnitude_b = sum(value * value for value in vector_b) ** 0.5

    if magnitude_a == 0 or magnitude_b == 0:
        return 0.0

    return dot_product / (magnitude_a * magnitude_b)


def _has_location_preferences(preferences: dict[str, Any]) -> bool:
    return bool(_clean_text(preferences.get("province"))) or bool(_clean_text(preferences.get("state")))


def location_score(room: Room, preferences: dict[str, Any]) -> float:
    """Score location independently from the feature vector.

    Exact province/state matches score highest. When only one location field is
    provided, that single field determines the score.
    """

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


def _gender_vector(value: str | None) -> list[int] | None:
    normalized = _clean_text(value)
    if normalized not in GENDER_FEATURES:
        return None

    return [1 if normalized == gender else 0 for gender in GENDER_FEATURES]


def _build_feature_vector(
    room: Room,
    preferences: dict[str, Any],
    min_price: float,
    max_price: float,
) -> tuple[list[float], list[float]]:
    """Create aligned room and preference vectors using only active features."""

    room_vector: list[float] = []
    preference_vector: list[float] = []

    preferred_price = preferences.get("preferred_price")
    if preferred_price is not None:
        room_vector.append(_normalize_price(room.price, min_price, max_price))
        preference_vector.append(_normalize_price(preferred_price, min_price, max_price))

    for feature_name in BOOLEAN_FEATURES:
        if feature_name in preferences and preferences.get(feature_name) is not None:
            room_vector.append(_to_bool(getattr(room, feature_name)))
            preference_vector.append(_to_bool(preferences.get(feature_name)))

    preferred_gender = _clean_text(preferences.get("gender_preference"))
    room_gender = _clean_text(room.gender_preference)
    if preferred_gender in GENDER_FEATURES and room_gender in GENDER_FEATURES:
        room_gender_vector = _gender_vector(room.gender_preference)
        preference_gender_vector = _gender_vector(preferences.get("gender_preference"))

        if room_gender_vector and preference_gender_vector:
            room_vector.extend(room_gender_vector)
            preference_vector.extend(preference_gender_vector)

    return room_vector, preference_vector


def recommend_rooms(
    rooms: list[Room] | Any,
    preferences: dict[str, Any],
) -> list[RecommendationScore]:
    """Rank rooms using cosine similarity and separate location matching.

    The active room set is expected to be filtered to available rooms before
    this function is called.
    """

    active_rooms = list(rooms)
    if not active_rooms:
        return []

    prices = [float(room.price) for room in active_rooms if room.price is not None]
    min_price = min(prices) if prices else 0.0
    max_price = max(prices) if prices else 0.0

    results: list[RecommendationScore] = []
    location_active = _has_location_preferences(preferences)

    for room in active_rooms:
        room_vector, preference_vector = _build_feature_vector(room, preferences, min_price, max_price)
        cosine_score = cosine_similarity(room_vector, preference_vector)

        current_location_score = location_score(room, preferences)
        if location_active:
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
