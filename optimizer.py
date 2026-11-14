from decimal import Decimal
from db import query

WEIGHTS = {
    "Budget":   {"cost": 0.60, "time": 0.30, "comfort": 0.10},
    "Moderate": {"cost": 0.40, "time": 0.40, "comfort": 0.20},
    "Luxury":   {"cost": 0.15, "time": 0.30, "comfort": 0.55},
}

COMFORT_SCORE = {"Low": 1, "Medium": 2, "High": 3}


def _f(v, default=0.0):
    """Convert any numeric type (Decimal, int, float, str, None) to float."""
    if v is None:
        return default
    try:
        return float(v)
    except (TypeError, ValueError):
        return default


def _i(v, default=0):
    """Convert any numeric type to int."""
    if v is None:
        return default
    try:
        return int(v)
    except (TypeError, ValueError):
        return default


def score_route(route, style):
    """Lower score = better route."""
    if not route:
        return float("inf")

    w = WEIGHTS.get(style, WEIGHTS["Moderate"])

    cost = _f(route.get("estimated_cost"), 0.0)
    time_ = _i(route.get("travel_time"), 0)

    comfort = route.get("comfort_level") or "Medium"
    comfort_val = COMFORT_SCORE.get(comfort, 2)

    cost_norm = min(cost / 500.0, 1.0)
    time_norm = min(time_ / 120.0, 1.0)
    comfort_norm = 1 - (comfort_val / 3.0)

    return (w["cost"] * cost_norm
            + w["time"] * time_norm
            + w["comfort"] * comfort_norm)


def best_route_between(src, dst, style):
    """Find best route between two places. Returns None if no route."""
    if src is None or dst is None or src == dst:
        return None

    routes = query(
        """SELECT r.*, t.transport_type FROM ROUTE r
           JOIN TRANSPORT t ON r.transport_id = t.transport_id
           WHERE r.source_place_id=%s AND r.destination_place_id=%s""",
        (src, dst)
    )
    if not routes:
        routes = query(
            """SELECT r.*, t.transport_type FROM ROUTE r
               JOIN TRANSPORT t ON r.transport_id = t.transport_id
               WHERE r.source_place_id=%s AND r.destination_place_id=%s""",
            (dst, src)
        )
    if not routes:
        return None
    return min(routes, key=lambda r: score_route(r, style))


def build_itinerary(place_ids, style, start_minutes=9 * 60):
    """Build itinerary. Handles missing places and routes."""
    if not place_ids:
        return [], 0.0, 0

    place_map = {}
    for pid in place_ids:
        try:
            rows = query("SELECT * FROM PLACE WHERE place_id=%s", (pid,))
            if rows:
                place_map[pid] = rows[0]
        except Exception as e:
            print(f"Warning: could not fetch place {pid}: {e}")

    if not place_map:
        return [], 0.0, 0

    remaining = list(place_map.keys())
    current = remaining.pop(0)
    ordered = [current]

    # --- Greedy ordering ---
    while remaining:
        best_next, best_route, best_score = None, None, float("inf")
        for nxt in remaining:
            try:
                r = best_route_between(current, nxt, style)
            except Exception as e:
                print(f"Warning: route lookup failed: {e}")
                r = None
            if r is None:
                continue
            s = score_route(r, style)
            if s < best_score:
                best_score, best_next, best_route = s, nxt, r

        if best_next is None:
            best_next = remaining[0]
            best_route = None

        remaining.remove(best_next)
        ordered.append((best_next, best_route))
        current = best_next

    # --- Build legs ---
    legs = []
    clock = start_minutes
    total_cost = 0.0

    first = place_map[ordered[0]]
    first_dur = _i(first.get("visit_duration"), 60)
    first_fee = _f(first.get("entry_fee"), 0.0)

    legs.append({
        "place": first,
        "arrival": clock,
        "departure": clock + first_dur,
        "transport": None,
        "travel_cost": 0.0,
    })
    clock += first_dur
    total_cost += first_fee

    for item in ordered[1:]:
        nxt, route = item
        place = place_map.get(nxt)
        if not place:
            continue

        place_dur = _i(place.get("visit_duration"), 60)
        place_fee = _f(place.get("entry_fee"), 0.0)

        travel_cost = 0.0
        if route:
            travel_time = _i(route.get("travel_time"), 0)
            travel_cost = _f(route.get("estimated_cost"), 0.0)
            clock += travel_time
            total_cost += travel_cost

        legs.append({
            "place": place,
            "arrival": clock,
            "departure": clock + place_dur,
            "transport": route,
            "travel_cost": travel_cost,
        })
        clock += place_dur
        total_cost += place_fee

    total_time = clock - start_minutes
    return legs, round(total_cost, 2), total_time


def minutes_to_hhmm(m):
    """Convert minutes since midnight to 'HH:MM'."""
    try:
        m = int(m)
    except (TypeError, ValueError):
        m = 0
    return f"{m // 60:02d}:{m % 60:02d}"