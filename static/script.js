// ================= STATE =================
let currentPlan = null;

// ================= SECTION NAV =================
function showSection(name) {
    document.querySelectorAll(".section").forEach(s => s.classList.remove("active"));
    const el = document.getElementById("section-" + name);
    if (el) el.classList.add("active");
    window.scrollTo(0, 0);

    if (name === "dashboard") loadDashboard();
    if (name === "trips") loadTrips();
    if (name === "admin") loadAdmin();
}

// ================= FLASH =================
function flash(msg, type = "info") {
    const box = document.createElement("div");
    box.className = "flash " + type;
    box.textContent = msg;
    document.getElementById("flash-container").appendChild(box);
    setTimeout(() => box.remove(), 3200);
}

// ================= API HELPERS =================
async function api(url, opts = {}) {
    const res = await fetch(url, {
        headers: { "Content-Type": "application/json" },
        ...opts,
    });
    const data = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(data.error || "Request failed");
    return data;
}

// ================= AUTH =================
async function checkAuth() {
    const me = await api("/api/me");
    const navDash = document.getElementById("nav-dash");
    const navTrips = document.getElementById("nav-trips");
    const navAdmin = document.getElementById("nav-admin");
    const navUser = document.getElementById("nav-user");
    const authBtn = document.getElementById("nav-auth-btn");

    if (me.logged_in) {
        navDash.classList.remove("hidden");
        navTrips.classList.remove("hidden");
        navUser.classList.remove("hidden");
        navUser.textContent = "👤 " + me.name;
        authBtn.textContent = "Logout";
        authBtn.onclick = doLogout;
        if (me.role === "admin") navAdmin.classList.remove("hidden");
        else navAdmin.classList.add("hidden");
    } else {
        navDash.classList.add("hidden");
        navTrips.classList.add("hidden");
        navAdmin.classList.add("hidden");
        navUser.classList.add("hidden");
        authBtn.textContent = "Login";
        authBtn.onclick = () => showSection("auth-login");
    }
}

function handleAuthClick() {}

async function doLogin(e) {
    e.preventDefault();
    const email = document.getElementById("login-email").value;
    const password = document.getElementById("login-password").value;
    try {
        const res = await api("/api/login", {
            method: "POST",
            body: JSON.stringify({ email, password }),
        });
        flash("Welcome, " + res.name + "!", "success");
        await checkAuth();
        showSection(res.role === "admin" ? "admin" : "dashboard");
    } catch (err) {
        flash(err.message, "danger");
    }
}

async function doRegister(e) {
    e.preventDefault();
    const payload = {
        name: document.getElementById("reg-name").value,
        email: document.getElementById("reg-email").value,
        phone: document.getElementById("reg-phone").value,
        password: document.getElementById("reg-password").value,
        preferred_mode: document.getElementById("reg-mode").value,
    };
    try {
        await api("/api/register", { method: "POST", body: JSON.stringify(payload) });
        flash("Registration successful. Please log in.", "success");
        showSection("auth-login");
    } catch (err) {
        flash(err.message, "danger");
    }
}

async function doLogout() {
    await api("/api/logout", { method: "POST" });
    flash("Logged out", "info");
    await checkAuth();
    showSection("home");
}

// ================= HOME / DESTINATION CARDS =================
async function loadHome() {
    try {
        const dests = await api("/api/destinations");
        const box = document.getElementById("home-destinations");
        if (!box) return;

        box.innerHTML = dests.map(d => {
            const img = getDestinationImage(d.destination_name);
            // Added onclick here to open the modal
            return `
                <div class="card destination-card" 
                     style="background-image: url('${img}')"
                     onclick="openDestinationModal(${d.destination_id}, '${d.destination_name}', '${d.state}', '${img}')">
                    <div class="destination-overlay">
                        <h3>${d.destination_name}</h3>
                        <p>${d.state || ""}</p>
                    </div>
                </div>
            `;
        }).join("");
    } catch (err) {
        console.error("Failed to load destinations:", err);
    }
}

// ===== DESTINATION IMAGES =====
function getDestinationImage(name) {
    const slug = name.toLowerCase().replace(/\s+/g, '-');
    return `/static/images/${slug}.jpg`;
}

// ================= DASHBOARD (Plan Trip) =================
async function loadDashboard() {
    const me = await api("/api/me");
    document.getElementById("welcome-name").textContent = me.name || "";

    const dests = await api("/api/destinations");
    const sel = document.getElementById("plan-destination");
    sel.innerHTML = '<option value="">-- select --</option>' +
        dests.map(d => `<option value="${d.destination_id}">${d.destination_name}</option>`).join("");
}

async function loadPlaces() {
    const id = document.getElementById("plan-destination").value;
    const box = document.getElementById("places-list");
    if (!id) { box.innerHTML = "Select a destination first."; return; }
    box.innerHTML = "Loading...";
    try {
        const places = await api("/api/places/" + id);
        if (!places.length) { box.innerHTML = "No places available."; return; }
        box.innerHTML = places.map(p => `
            <label>
                <input type="checkbox" name="places" value="${p.place_id}">
                <span>${p.place_name} <br><small class="muted">⭐${p.rating} • ₹${p.entry_fee} • ${p.visit_duration}min</small></span>
            </label>
        `).join("");
    } catch (e) {
        box.innerHTML = "Error loading places.";
    }
}

// ================= PLAN =================
async function generatePlan(e) {
    e.preventDefault();
    const start = document.getElementById("plan-start").value;
    const destination_id = document.getElementById("plan-destination").value;
    const travel_style = document.getElementById("plan-style").value;
    const place_ids = Array.from(document.querySelectorAll('#places-list input:checked'))
        .map(c => c.value);

    if (!place_ids.length) { flash("Select at least one place", "warning"); return; }

    try {
        const plan = await api("/api/plan", {
            method: "POST",
            body: JSON.stringify({ start_location: start, destination_id, travel_style, place_ids }),
        });
        currentPlan = plan;
        renderPlan(plan);
        showSection("itinerary");
    } catch (err) {
        flash(err.message, "danger");
    }
}

function renderPlan(plan) {
    document.getElementById("itinerary-summary").innerHTML = `
        <div class="card">
            <p><b>Travel Style:</b> ${plan.travel_style}</p>
            <p><b>Estimated Total Cost:</b> ₹${plan.total_cost}</p>
            <p><b>Estimated Total Time:</b> ${plan.total_time} min</p>
        </div>
    `;

    const rows = plan.legs.map((leg, i) => `
        <tr>
            <td>${i + 1}</td>
            <td>${leg.place_name} <small class="muted">(${leg.category || ""})</small></td>
            <td>${leg.arrival}</td>
            <td>${leg.departure}</td>
            <td>${leg.transport || "—"}</td>
            <td>₹${leg.travel_cost}</td>
            <td>₹${leg.entry_fee}</td>
        </tr>
    `).join("");

    document.getElementById("itinerary-table").innerHTML = `
        <table class="table">
            <thead><tr>
                <th>#</th><th>Place</th><th>Arrival</th><th>Departure</th>
                <th>Transport</th><th>Travel Cost</th><th>Entry Fee</th>
            </tr></thead>
            <tbody>${rows}</tbody>
        </table>
    `;
}

async function saveTrip() {
    if (!currentPlan) return;
    try {
        const payload = {
            destination_id: currentPlan.destination_id,
            start_location: currentPlan.start_location,
            travel_style: currentPlan.travel_style,
            place_ids: currentPlan.legs.map(l => l.place_id),
        };
        const res = await api("/api/save_trip", {
            method: "POST",
            body: JSON.stringify(payload),
        });
        flash("Trip saved! (ID " + res.trip_id + ")", "success");
        currentPlan = null;
        showSection("trips");
    } catch (err) {
        flash(err.message, "danger");
    }
}

// ================= MY TRIPS =================
async function loadTrips() {
    const trips = await api("/api/trips");
    const box = document.getElementById("trips-body");
    if (!trips.length) {
        box.innerHTML = '<p>No trips yet. <a href="#" onclick="showSection(\'dashboard\')">Plan one!</a></p>';
        return;
    }
    box.innerHTML = `
        <table class="table">
            <thead><tr>
                <th>ID</th><th>Destination</th><th>Style</th>
                <th>Date</th><th>Cost</th><th>Time</th><th></th>
            </tr></thead>
            <tbody>
                ${trips.map(t => `
                    <tr>
                        <td>${t.trip_id}</td>
                        <td>${t.destination_name}</td>
                        <td>${t.travel_style}</td>
                        <td>${t.trip_date ? t.trip_date.split(" ")[0] : ""}</td>
                        <td>₹${t.total_cost}</td>
                        <td>${t.total_time} min</td>
                        <td><button class="btn small" onclick="viewTrip(${t.trip_id})">View</button></td>
                    </tr>
                `).join("")}
            </tbody>
        </table>
    `;
}

async function viewTrip(id) {
    try {
        const data = await api("/api/trip/" + id);
        const { trip, itinerary, expenses } = data;

        document.getElementById("trip-detail-body").innerHTML = `
            <div class="card">
                <p><b>Destination:</b> ${trip.destination_name}</p>
                <p><b>Style:</b> ${trip.travel_style}</p>
                <p><b>Date:</b> ${trip.trip_date || ""}</p>
                <p><b>Total Cost:</b> ₹${trip.total_cost} | <b>Total Time:</b> ${trip.total_time} min</p>
            </div>

            <h3>Schedule</h3>
            <table class="table">
                <thead><tr>
                    <th>Arrival</th><th>Departure</th><th>Place</th>
                    <th>Transport</th><th>Cost</th>
                </tr></thead>
                <tbody>
                    ${itinerary.map(i => `
                        <tr>
                            <td>${i.arrival_time || ""}</td>
                            <td>${i.departure_time || ""}</td>
                            <td>${i.place_name || "—"}</td>
                            <td>${i.transport_type || "—"}</td>
                            <td>₹${i.travel_cost}</td>
                        </tr>
                    `).join("")}
                </tbody>
            </table>

            <h3>Expenses</h3>
            <ul>
                ${expenses.map(e => `<li>${e.expense_type}: ₹${e.amount} — ${e.description || ""}</li>`).join("")}
            </ul>
        `;
        showSection("trip-detail");
    } catch (err) {
        flash(err.message, "danger");
    }
}

// ================= ADMIN =================
async function loadAdmin() {
    try {
        const data = await api("/api/admin/stats");
        const s = data.stats;
        document.getElementById("admin-stats").innerHTML = `
            <div class="stat"><span>${s.destinations}</span><label>Destinations</label></div>
            <div class="stat"><span>${s.places}</span><label>Places</label></div>
            <div class="stat"><span>${s.routes}</span><label>Routes</label></div>
            <div class="stat"><span>${s.users}</span><label>Users</label></div>
            <div class="stat"><span>${s.trips}</span><label>Trips</label></div>
        `;

        document.getElementById("admin-popular").innerHTML = `
            <table class="table">
                <thead><tr><th>Place</th><th>Destination</th><th>Selections</th></tr></thead>
                <tbody>
                    ${data.popular.map(p => `
                        <tr>
                            <td>${p.place_name}</td>
                            <td>${p.destination_name}</td>
                            <td>${p.selection_count}</td>
                        </tr>
                    `).join("")}
                </tbody>
            </table>
        `;
    } catch (err) {
        flash(err.message, "danger");
    }
}

async function addDestination(e) {
    e.preventDefault();
    try {
        await api("/api/admin/destination", {
            method: "POST",
            body: JSON.stringify({
                name: document.getElementById("ad-name").value,
                state: document.getElementById("ad-state").value,
                country: document.getElementById("ad-country").value,
                description: document.getElementById("ad-desc").value,
            })
        });
        flash("Destination added", "success");
        e.target.reset();
        loadAdmin();
    } catch (err) { flash(err.message, "danger"); }
}

async function addPlace(e) {
    e.preventDefault();
    try {
        await api("/api/admin/place", {
            method: "POST",
            body: JSON.stringify({
                destination_id: document.getElementById("ap-dest").value,
                place_name: document.getElementById("ap-name").value,
                category: document.getElementById("ap-cat").value,
                rating: document.getElementById("ap-rating").value || 0,
                entry_fee: document.getElementById("ap-fee").value || 0,
                visit_duration: document.getElementById("ap-dur").value || 60,
            })
        });
        flash("Place added", "success");
        e.target.reset();
        loadAdmin();
    } catch (err) { flash(err.message, "danger"); }
}

async function addRoute(e) {
    e.preventDefault();
    try {
        await api("/api/admin/route", {
            method: "POST",
            body: JSON.stringify({
                source_place_id: document.getElementById("ar-src").value,
                destination_place_id: document.getElementById("ar-dst").value,
                transport_id: document.getElementById("ar-tid").value,
                distance: document.getElementById("ar-dist").value || 0,
                travel_time: document.getElementById("ar-time").value || 0,
                estimated_cost: document.getElementById("ar-cost").value || 0,
                comfort_level: document.getElementById("ar-comfort").value,
            })
        });
        flash("Route added", "success");
        e.target.reset();
        loadAdmin();
    } catch (err) { flash(err.message, "danger"); }
}

// ================= MAKEMYTRIP STYLE MODAL =================
async function openDestinationModal(id, name, state, imgUrl) {
    const modal = document.getElementById("destination-modal");
    if (!modal) return; // Prevent errors if HTML isn't loaded

    modal.classList.remove("hidden");
    
    document.getElementById("modal-title").textContent = name;
    document.getElementById("modal-subtitle").textContent = state;
    document.getElementById("modal-hero").style.backgroundImage = `url('${imgUrl}')`;
    
    const placesDiv = document.getElementById("modal-places");
    const travelDiv = document.getElementById("modal-travel");
    const hotelsDiv = document.getElementById("modal-hotels");
    const foodDiv = document.getElementById("modal-food");
    const styleBadge = document.getElementById("user-style-badge");
    
    placesDiv.innerHTML = "<p>Loading...</p>";
    hotelsDiv.innerHTML = "<p>Loading...</p>";
    foodDiv.innerHTML = "<p>Loading...</p>";
    travelDiv.innerHTML = "<p>Loading...</p>";

    try {
        const data = await api(`/api/destination_details/${id}`);
        
        // Show user's travel style in the header
        const userStyle = data.user_style; // Budget, Moderate, Luxury
        if (styleBadge) styleBadge.textContent = `Showing: ${userStyle} options`;

        // 1. Render Tourist Places (Always show all)
        if (data.places && data.places.length > 0) {
            placesDiv.innerHTML = data.places.map(p => `
                <div class="modal-item">
                    <div>
                        <span class="rating-badge">⭐ ${p.rating}</span>
                        <h4>${p.place_name}</h4>
                        <p>${p.category || 'Attraction'}</p>
                    </div>
                    <span class="price-tag">Entry: ₹${p.entry_fee}</span>
                </div>
            `).join("");
        } else {
            placesDiv.innerHTML = "<p>No places data available.</p>";
        }

        // 2. Render Travel Options
        if (data.travel_options && data.travel_options.length > 0) {
            travelDiv.innerHTML = data.travel_options.map(t => `
                <div class="modal-item">
                    <h4>${t.mode}</h4>
                    <p>${t.info}</p>
                    <span class="price-tag">${t.price}</span>
                    <p style="margin-top:5px; font-size:0.8rem;">⏱️ ${t.time}</p>
                </div>
            `).join("");
        }

        // 3. Filter & Render Hotels
        let allHotels = data.stay_food.filter(item => item.type === 'Hotel' || item.type === 'Lodge');
        let filteredHotels = [];

        if (userStyle === 'Budget') {
            filteredHotels = allHotels.filter(h => h.price_range.includes('500') || h.price_range.includes('1,000') || h.price_range.includes('2,000') || h.price_range.includes('5,000'));
        } else if (userStyle === 'Luxury') {
            filteredHotels = allHotels.filter(h => h.price_range.includes('00,000') || h.price_range.includes('5,000+') || h.price_range.includes('8,000+') || h.price_range.includes('12,000+'));
        } else {
            filteredHotels = allHotels.filter(h => h.price_range.includes('3,000') || h.price_range.includes('5,000') || h.price_range.includes('6,000') || h.price_range.includes('8,000'));
        }
        
        // If filter is too strict, just show everything
        if (filteredHotels.length === 0) filteredHotels = allHotels;

        hotelsDiv.innerHTML = filteredHotels.map(h => `
            <div class="modal-item">
                <div>
                    <span class="rating-badge">⭐ ${h.rating}</span>
                    <h4>${h.name}</h4>
                    <p>${h.type} • ${h.description}</p>
                </div>
                <div>
                    <span class="price-tag">${h.price_range}</span>
                    <button class="btn-view">Book Now</button>
                </div>
            </div>
        `).join("");

        // 4. Filter & Render Food
        let allFood = data.stay_food.filter(item => item.type === 'Restaurant' || item.type === 'Sweet Shop');
        let filteredFood = [];

        if (userStyle === 'Budget') {
            filteredFood = allFood.filter(f => f.price_range.includes('200') || f.price_range.includes('300') || f.price_range.includes('400') || f.price_range.includes('500'));
        } else if (userStyle === 'Luxury') {
            filteredFood = allFood.filter(f => f.price_range.includes('5,000') || f.price_range.includes('1,500') || f.price_range.includes('1,200'));
        } else {
            filteredFood = allFood.filter(f => f.price_range.includes('600') || f.price_range.includes('800') || f.price_range.includes('1,000'));
        }

        if (filteredFood.length === 0) filteredFood = allFood;

        foodDiv.innerHTML = filteredFood.map(f => `
            <div class="modal-item">
                <div>
                    <span class="rating-badge">⭐ ${f.rating}</span>
                    <h4>${f.name}</h4>
                    <p>${f.type} • ${f.description}</p>
                </div>
                <div>
                    <span class="price-tag">${f.price_range}</span>
                    <button class="btn-view">View Menu</button>
                </div>
            </div>
        `).join("");

    } catch (err) {
        console.error(err);
        placesDiv.innerHTML = "<p style='color:red'>Error loading details.</p>";
    }
}

function closeModal() {
    document.getElementById("destination-modal").classList.add("hidden");
}

// Close modal when clicking outside the white box
document.addEventListener("click", function(e) {
    const modal = document.getElementById("destination-modal");
    if (modal && e.target === modal) {
        closeModal();
    }
});


// ================= INIT =================
(async function init() {
    await checkAuth();
    await loadHome();
    showSection("home");
})();