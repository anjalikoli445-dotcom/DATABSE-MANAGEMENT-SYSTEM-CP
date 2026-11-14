DROP DATABASE IF EXISTS tripwise;
CREATE DATABASE tripwise CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE tripwise;

CREATE TABLE USER (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(15),
    password_hash VARCHAR(255) NOT NULL,
    preferred_mode ENUM('Budget','Moderate','Luxury') DEFAULT 'Moderate',
    role ENUM('user','admin') DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE DESTINATION (
    destination_id INT AUTO_INCREMENT PRIMARY KEY,
    destination_name VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    country VARCHAR(100) DEFAULT 'India',
    description TEXT
);

CREATE TABLE PLACE (
    place_id INT AUTO_INCREMENT PRIMARY KEY,
    destination_id INT NOT NULL,
    place_name VARCHAR(150) NOT NULL,
    category VARCHAR(50),
    description TEXT,
    rating DECIMAL(2,1) DEFAULT 0.0,
    entry_fee DECIMAL(10,2) DEFAULT 0.00,
    visit_duration INT DEFAULT 60,
    FOREIGN KEY (destination_id) REFERENCES DESTINATION(destination_id) ON DELETE CASCADE
);

CREATE TABLE TRANSPORT (
    transport_id INT AUTO_INCREMENT PRIMARY KEY,
    transport_type VARCHAR(50) NOT NULL UNIQUE,
    comfort_level ENUM('Low','Medium','High') DEFAULT 'Medium'
);

CREATE TABLE ROUTE (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    source_place_id INT NOT NULL,
    destination_place_id INT NOT NULL,
    transport_id INT NOT NULL,
    distance DECIMAL(6,2),
    travel_time INT,
    estimated_cost DECIMAL(10,2),
    comfort_level ENUM('Low','Medium','High') DEFAULT 'Medium',
    FOREIGN KEY (source_place_id) REFERENCES PLACE(place_id) ON DELETE CASCADE,
    FOREIGN KEY (destination_place_id) REFERENCES PLACE(place_id) ON DELETE CASCADE,
    FOREIGN KEY (transport_id) REFERENCES TRANSPORT(transport_id) ON DELETE CASCADE
);

CREATE TABLE TRIP (
    trip_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    destination_id INT NOT NULL,
    start_location VARCHAR(100),
    travel_style ENUM('Budget','Moderate','Luxury') NOT NULL,
    trip_date DATE,
    total_cost DECIMAL(12,2) DEFAULT 0.00,
    total_time INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USER(user_id) ON DELETE CASCADE,
    FOREIGN KEY (destination_id) REFERENCES DESTINATION(destination_id) ON DELETE CASCADE
);

CREATE TABLE SELECTED_PLACE (
    trip_id INT NOT NULL,
    place_id INT NOT NULL,
    visit_order INT NOT NULL,
    planned_duration INT,
    PRIMARY KEY (trip_id, place_id),
    FOREIGN KEY (trip_id) REFERENCES TRIP(trip_id) ON DELETE CASCADE,
    FOREIGN KEY (place_id) REFERENCES PLACE(place_id) ON DELETE CASCADE
);

CREATE TABLE ITINERARY (
    itinerary_id INT AUTO_INCREMENT PRIMARY KEY,
    trip_id INT NOT NULL,
    place_id INT,
    transport_id INT,
    arrival_time TIME,
    departure_time TIME,
    travel_cost DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (trip_id) REFERENCES TRIP(trip_id) ON DELETE CASCADE,
    FOREIGN KEY (place_id) REFERENCES PLACE(place_id) ON DELETE SET NULL,
    FOREIGN KEY (transport_id) REFERENCES TRANSPORT(transport_id) ON DELETE SET NULL
);

CREATE TABLE EXPENSE (
    expense_id INT AUTO_INCREMENT PRIMARY KEY,
    trip_id INT NOT NULL,
    expense_type ENUM('Transportation','Food','Entry Fee','Hotel','Other') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    description VARCHAR(255),
    FOREIGN KEY (trip_id) REFERENCES TRIP(trip_id) ON DELETE CASCADE
);

CREATE TABLE EXPENSE_LOG (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    trip_id INT,
    deleted_amount DECIMAL(10,2),
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE VIEW vw_popular_places AS
SELECT p.place_id, p.place_name, d.destination_name,
       COUNT(sp.trip_id) AS selection_count
FROM PLACE p
JOIN DESTINATION d ON p.destination_id = d.destination_id
LEFT JOIN SELECTED_PLACE sp ON p.place_id = sp.place_id
GROUP BY p.place_id, p.place_name, d.destination_name
ORDER BY selection_count DESC;

CREATE VIEW vw_user_trip_summary AS
SELECT t.trip_id, u.name AS user_name, d.destination_name,
       t.travel_style, t.total_cost, t.total_time, t.trip_date
FROM TRIP t
JOIN USER u ON t.user_id = u.user_id
JOIN DESTINATION d ON t.destination_id = d.destination_id;

DELIMITER //
CREATE PROCEDURE GetDestinationPlaces(IN dest_id INT)
BEGIN
    SELECT place_id, place_name, category, rating, entry_fee, visit_duration
    FROM PLACE WHERE destination_id = dest_id ORDER BY rating DESC;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_expense_after_delete
AFTER DELETE ON EXPENSE
FOR EACH ROW
BEGIN
    INSERT INTO EXPENSE_LOG (trip_id, deleted_amount)
    VALUES (OLD.trip_id, OLD.amount);
END //
DELIMITER ;