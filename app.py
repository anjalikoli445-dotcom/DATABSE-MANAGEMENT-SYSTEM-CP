from functools import wraps
from datetime import date
import traceback

from flask import Flask, render_template, request, session, jsonify
from werkzeug.security import generate_password_hash, check_password_hash

from config import Config
from db import query, get_conn
from optimizer import build_itinerary, minutes_to_hhmm

app = Flask(__name__)
app.config.from_object(Config)


# ---------- Global error handler ----------
@app.errorhandler(Exception)
def handle_error(e):
    print("\n========= FLASK ERROR =========")
    traceback.print_exc()
    print("================================\n")
    return {"error": str(e)}, 500


# ---------- Decorators ----------
def login_required(f):
    @wraps(f)
    def wrapper(*a, **kw):
        if "user_id" not in session:
            return jsonify({"error": "login required"}), 401
        return f(*a, **kw)
    return wrapper


def admin_required(f):
    @wraps(f)
    def wrapper(*a, **kw):
        if session.get("role") != "admin":
            return jsonify({"error": "admin required"}), 403
        return f(*a, **kw)
    return wrapper


# ---------- Serialization helpers ----------
def fmt_time(v):
    """timedelta or time -> 'HH:MM'"""
    if v is None:
        return None
    if hasattr(v, "total_seconds"):
        total = int(v.total_seconds())
        h, rem = divmod(abs(total), 3600)
        m, s = divmod(rem, 60)
        return f"{h:02d}:{m:02d}"
    if hasattr(v, "strftime"):
        return v.strftime("%H:%M")
    return str(v)


def fmt_date(v):
    """date/datetime -> 'YYYY-MM-DD'"""
    if v is None:
        return None
    if hasattr(v, "strftime"):
        return v.strftime("%Y-%m-%d")
    return str(v)


def num(v, default=0.0):
    """Any numeric type -> float"""
    try:
        return float(v) if v is not None else default
    except Exception:
        return default


def integer(v, default=0):
    """Any numeric type -> int"""
    try:
        return int(v) if v is not None else default
    except Exception:
        return default


# ---------- Page ----------
@app.route("/")
def index():
    return render_template("index.html")


# ---------- Auth API ----------
@app.route("/api/register", methods=["POST"])
def api_register():
    d = request.get_json()
    name = d.get("name", "").strip()
    email = d.get("email", "").strip().lower()
    phone = d.get("phone", "").strip()
    password = d.get("password", "")
    mode = d.get("preferred_mode", "Moderate")

    if not name or not email or not password:
        return jsonify({"error": "All fields required"}), 400

    existing = query("SELECT user_id FROM USER WHERE email=%s", (email,))
    if existing:
        return jsonify({"error": "Email already registered"}), 400

    pw_hash = generate_password_hash(password)
    query(
        """INSERT INTO USER (name, email, phone, password_hash, preferred_mode, role)
           VALUES (%s,%s,%s,%s,%s,'user')""",
        (name, email, phone, pw_hash, mode), fetch=False
    )
    return jsonify({"message": "Registration successful"})


@app.route("/api/login", methods=["POST"])
def api_login():
    d = request.get_json()
    email = d.get("email", "").strip().lower()
    password = d.get("password", "")

    rows = query("SELECT * FROM USER WHERE email=%s", (email,))
    if not rows or not check_password_hash(rows[0]["password_hash"], password):
        return jsonify({"error": "Invalid credentials"}), 401

    u = rows[0]
    session["user_id"] = u["user_id"]
    session["name"] = u["name"]
    session["role"] = u["role"]
    return jsonify({
        "message": "Logged in",
        "name": u["name"],
        "role": u["role"],
    })


@app.route("/api/logout", methods=["POST"])
def api_logout():
    session.clear()
    return jsonify({"message": "Logged out"})


@app.route("/api/me")
def api_me():
    if "user_id" not in session:
        return jsonify({"logged_in": False})
    return jsonify({
        "logged_in": True,
        "user_id": session["user_id"],
        "name": session["name"],
        "role": session["role"],
    })


# ---------- Data API ----------
@app.route("/api/destinations")
def api_destinations():
    rows = query("SELECT * FROM DESTINATION ORDER BY destination_name")
    return jsonify(rows)


@app.route("/api/places/<int:dest_id>")
def api_places(dest_id):
    rows = query(
        "SELECT * FROM PLACE WHERE destination_id=%s ORDER BY rating DESC",
        (dest_id,)
    )
    for r in rows:
        r["entry_fee"] = num(r.get("entry_fee"))
        r["rating"] = num(r.get("rating"))
        r["visit_duration"] = integer(r.get("visit_duration"))
    return jsonify(rows)


# ---------- Plan (preview, not saved) ----------
@app.route("/api/plan", methods=["POST"])
@login_required
def api_plan():
    d = request.get_json()
    place_ids = [int(p) for p in d.get("place_ids", [])]
    style = d.get("travel_style", "Moderate")
    destination_id = d.get("destination_id")
    start_location = d.get("start_location", "")

    if not place_ids:
        return jsonify({"error": "Select at least one place"}), 400

    try:
        legs, total_cost, total_time = build_itinerary(place_ids, style)
    except Exception as e:
        print("=== OPTIMIZER ERROR ===")
        traceback.print_exc()
        return jsonify({"error": f"Optimization failed: {str(e)}"}), 500

    return jsonify({
        "destination_id": destination_id,
        "start_location": start_location,
        "travel_style": style,
        "total_cost": num(total_cost),
        "total_time": integer(total_time),
        "legs": [{
            "place_id": leg["place"]["place_id"],
            "place_name": leg["place"].get("place_name") or "Unknown",
            "category": leg["place"].get("category") or "",
            "entry_fee": num(leg["place"].get("entry_fee")),
            "arrival": minutes_to_hhmm(leg["arrival"]),
            "departure": minutes_to_hhmm(leg["departure"]),
            "transport": leg["transport"]["transport_type"] if leg.get("transport") else None,
            "travel_cost": num(leg.get("travel_cost")),
        } for leg in legs]
    })


# ---------- Save trip (transaction) ----------
@app.route("/api/save_trip", methods=["POST"])
@login_required
def api_save_trip():
    d = request.get_json()
    destination_id = int(d["destination_id"])
    start_location = d.get("start_location", "")
    style = d["travel_style"]
    place_ids = [int(p) for p in d["place_ids"]]

    legs, total_cost, total_time = build_itinerary(place_ids, style)

    conn = get_conn()
    cur = conn.cursor()
    try:
        cur.execute(
            """INSERT INTO TRIP (user_id, destination_id, start_location,
                                 travel_style, trip_date, total_cost, total_time)
               VALUES (%s,%s,%s,%s,%s,%s,%s)""",
            (session["user_id"], destination_id, start_location, style,
             date.today(), total_cost, total_time)
        )
        trip_id = cur.lastrowid

        for idx, leg in enumerate(legs, start=1):
            cur.execute(
                """INSERT INTO SELECTED_PLACE (trip_id, place_id, visit_order, planned_duration)
                   VALUES (%s,%s,%s,%s)""",
                (trip_id, leg["place"]["place_id"], idx, leg["place"]["visit_duration"])
            )

        for leg in legs:
            cur.execute(
                """INSERT INTO ITINERARY (trip_id, place_id, transport_id,
                                          arrival_time, departure_time, travel_cost)
                   VALUES (%s,%s,%s,%s,%s,%s)""",
                (trip_id,
                 leg["place"]["place_id"],
                 leg["transport"]["transport_id"] if leg["transport"] else None,
                 minutes_to_hhmm(leg["arrival"]) + ":00",
                 minutes_to_hhmm(leg["departure"]) + ":00",
                 leg["travel_cost"])
            )

        cur.execute(
            """INSERT INTO EXPENSE (trip_id, expense_type, amount, description)
               VALUES (%s,'Entry Fee',%s,'Auto-generated')""",
            (trip_id, sum(num(l["place"].get("entry_fee")) for l in legs))
        )
        cur.execute(
            """INSERT INTO EXPENSE (trip_id, expense_type, amount, description)
               VALUES (%s,'Transportation',%s,'Auto-generated')""",
            (trip_id, sum(num(l.get("travel_cost")) for l in legs))
        )

        conn.commit()
        return jsonify({"message": "Trip saved", "trip_id": trip_id})
    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cur.close()
        conn.close()


# ---------- My Trips (list) ----------
@app.route("/api/trips")
@login_required
def api_trips():
    rows = query(
        """SELECT t.*, d.destination_name FROM TRIP t
           JOIN DESTINATION d ON t.destination_id = d.destination_id
           WHERE t.user_id=%s ORDER BY t.created_at DESC""",
        (session["user_id"],)
    )
    for r in rows:
        r["trip_date"] = fmt_date(r.get("trip_date"))
        r["created_at"] = fmt_date(r.get("created_at"))
        r["total_cost"] = num(r.get("total_cost"))
        r["total_time"] = integer(r.get("total_time"))
    return jsonify(rows)


# ---------- Trip detail ----------
@app.route("/api/trip/<int:trip_id>")
@login_required
def api_trip_detail(trip_id):
    rows = query(
        """SELECT t.*, d.destination_name FROM TRIP t
           JOIN DESTINATION d ON t.destination_id = d.destination_id
           WHERE t.trip_id=%s""", (trip_id,)
    )
    if not rows:
        return jsonify({"error": "Trip not found"}), 404
    trip = rows[0]
    if trip["user_id"] != session["user_id"] and session.get("role") != "admin":
        return jsonify({"error": "Not authorized"}), 403

    itinerary = query(
        """SELECT i.*, p.place_name, t.transport_type FROM ITINERARY i
           LEFT JOIN PLACE p ON i.place_id = p.place_id
           LEFT JOIN TRANSPORT t ON i.transport_id = t.transport_id
           WHERE i.trip_id=%s ORDER BY i.arrival_time""",
        (trip_id,)
    )
    expenses = query("SELECT * FROM EXPENSE WHERE trip_id=%s", (trip_id,))

    # Clean trip
    trip["trip_date"] = fmt_date(trip.get("trip_date"))
    trip["created_at"] = fmt_date(trip.get("created_at"))
    trip["total_cost"] = num(trip.get("total_cost"))
    trip["total_time"] = integer(trip.get("total_time"))

    # Clean itinerary
    for i in itinerary:
        i["arrival_time"] = fmt_time(i.get("arrival_time"))
        i["departure_time"] = fmt_time(i.get("departure_time"))
        i["travel_cost"] = num(i.get("travel_cost"))

    # Clean expenses
    for e in expenses:
        e["amount"] = num(e.get("amount"))

    return jsonify({"trip": trip, "itinerary": itinerary, "expenses": expenses})


# ---------- Admin API ----------
@app.route("/api/admin/stats")
@login_required
@admin_required
def api_admin_stats():
    stats = {
        "destinations": query("SELECT COUNT(*) c FROM DESTINATION")[0]["c"],
        "places": query("SELECT COUNT(*) c FROM PLACE")[0]["c"],
        "routes": query("SELECT COUNT(*) c FROM ROUTE")[0]["c"],
        "users": query("SELECT COUNT(*) c FROM USER")[0]["c"],
        "trips": query("SELECT COUNT(*) c FROM TRIP")[0]["c"],
    }
    popular = query("SELECT * FROM vw_popular_places LIMIT 5")
    return jsonify({"stats": stats, "popular": popular})


@app.route("/api/admin/destination", methods=["POST"])
@login_required
@admin_required
def api_add_destination():
    d = request.get_json()
    query(
        "INSERT INTO DESTINATION (destination_name, state, country, description) VALUES (%s,%s,%s,%s)",
        (d["name"], d.get("state"), d.get("country", "India"), d.get("description")),
        fetch=False
    )
    return jsonify({"message": "Destination added"})


@app.route("/api/admin/place", methods=["POST"])
@login_required
@admin_required
def api_add_place():
    d = request.get_json()
    query(
        """INSERT INTO PLACE (destination_id, place_name, category, rating,
                              entry_fee, visit_duration, description)
           VALUES (%s,%s,%s,%s,%s,%s,%s)""",
        (d["destination_id"], d["place_name"], d.get("category"),
         d.get("rating", 0), d.get("entry_fee", 0),
         d.get("visit_duration", 60), d.get("description")),
        fetch=False
    )
    return jsonify({"message": "Place added"})


@app.route("/api/admin/route", methods=["POST"])
@login_required
@admin_required
def api_add_route():
    d = request.get_json()
    query(
        """INSERT INTO ROUTE (source_place_id, destination_place_id, transport_id,
                              distance, travel_time, estimated_cost, comfort_level)
           VALUES (%s,%s,%s,%s,%s,%s,%s)""",
        (d["source_place_id"], d["destination_place_id"], d["transport_id"],
         d.get("distance", 0), d.get("travel_time", 0),
         d.get("estimated_cost", 0), d.get("comfort_level", "Medium")),
        fetch=False
    )
    return jsonify({"message": "Route added"})

# ---------- Fetch MakeMyTrip-style details for a destination ----------
@app.route("/api/destination_details/<int:dest_id>")
def api_destination_details(dest_id):
    # 1. Get destination info
    dest = query("SELECT * FROM DESTINATION WHERE destination_id=%s", (dest_id,))
    if not dest:
        return jsonify({"error": "Destination not found"}), 404

    # 2. Get tourist places
    places = query("SELECT * FROM PLACE WHERE destination_id=%s", (dest_id,))
    for p in places:
        p["entry_fee"] = num(p.get("entry_fee"))
        p["rating"] = num(p.get("rating"))

    # 3. Get hotels, food, etc.
    stay_food = query("SELECT * FROM STAY_AND_FOOD WHERE destination_id=%s", (dest_id,))
    for s in stay_food:
        s["rating"] = num(s.get("rating"))

    # 4. Check user's travel style (Budget/Moderate/Luxury)
    user_style = "Moderate" # Default
    if "user_id" in session:
        user_data = query("SELECT preferred_mode FROM USER WHERE user_id=%s", (session["user_id"],))
        if user_data:
            user_style = user_data[0]["preferred_mode"]

    # 5. Travel Options (Hardcoded real data for now)
    travel_options = []
    if dest_id == 5: # Agra
        travel_options = [
            {"mode": "Train", "price": "₹330+", "time": "2-3 hours", "info": "Fastest and most convenient"},
            {"mode": "Bus", "price": "₹200 - ₹500", "time": "4 hours", "info": "Frequent AC/Non-AC buses"},
            {"mode": "Taxi", "price": "₹3,000+", "time": "3.5 hours", "info": "Private cab, flexible timings"}
        ]
    elif dest_id == 1: # Mumbai
        travel_options = [
            {"mode": "Flight", "price": "₹4,500+", "time": "2 hours", "info": "Fastest option"},
            {"mode": "Train", "price": "₹2,500+", "time": "16 hours", "info": "Overnight journey"},
            {"mode": "Local Metro", "price": "₹10 - ₹50", "time": "Varies", "info": "Best for inside the city"}
        ]
    else:
        travel_options = [
            {"mode": "Flight / Train", "price": "Varies", "time": "Varies", "info": "Check local IRCTC or MakeMyTrip for routes"}
        ]

    return jsonify({
        "destination": dest[0],
        "places": places,
        "stay_food": stay_food,
        "user_style": user_style,
        "travel_options": travel_options
    })


if __name__ == "__main__":
    app.run(debug=True)
  
