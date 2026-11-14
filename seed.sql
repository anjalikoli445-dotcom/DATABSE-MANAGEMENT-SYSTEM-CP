USE tripwise;

INSERT INTO USER (name, email, phone, password_hash, preferred_mode, role) VALUES
('Admin', 'admin@tripwise.com', '9999999999', 'PLACEHOLDER_ADMIN', 'Luxury', 'admin'),
('Anushka', 'anushka@example.com', '9876543210', 'PLACEHOLDER_USER', 'Budget', 'user');

INSERT INTO DESTINATION (destination_name, state, description) VALUES
('Mumbai', 'Maharashtra', 'City of dreams, beaches and heritage'),
('Pune', 'Maharashtra', 'Cultural capital of Maharashtra'),
('Goa', 'Goa', 'Beaches, nightlife and Portuguese heritage'),
('Jaipur', 'Rajasthan', 'The Pink City with palaces and forts');

INSERT INTO PLACE (destination_id, place_name, category, rating, entry_fee, visit_duration) VALUES
(1, 'Gateway of India', 'Monument', 4.6, 0.00, 60),
(1, 'Marine Drive', 'Beach', 4.7, 0.00, 90),
(1, 'Juhu Beach', 'Beach', 4.3, 0.00, 120),
(1, 'Colaba Causeway', 'Market', 4.2, 0.00, 90),
(1, 'Elephanta Caves', 'Heritage', 4.5, 40.00, 180),
(2, 'Shaniwar Wada', 'Fort', 4.4, 25.00, 90),
(2, 'Aga Khan Palace', 'Heritage', 4.5, 20.00, 75),
(2, 'Dagdusheth Ganpati', 'Temple', 4.8, 0.00, 45),
(3, 'Baga Beach', 'Beach', 4.6, 0.00, 180),
(3, 'Fort Aguada', 'Fort', 4.4, 50.00, 90),
(4, 'Amber Fort', 'Fort', 4.7, 100.00, 180),
(4, 'Hawa Mahal', 'Monument', 4.5, 50.00, 60),
(4, 'City Palace', 'Palace', 4.6, 200.00, 120);

INSERT INTO TRANSPORT (transport_type, comfort_level) VALUES
('Walking', 'Low'), ('Auto', 'Medium'), ('Bus', 'Low'),
('Metro', 'Medium'), ('Cab', 'High'), ('Train', 'Medium');

INSERT INTO ROUTE (source_place_id, destination_place_id, transport_id, distance, travel_time, estimated_cost, comfort_level) VALUES
(1, 2, 3, 5.0, 25, 20.00, 'Low'),
(1, 2, 5, 5.0, 15, 180.00, 'High'),
(1, 2, 2, 5.0, 20, 100.00, 'Medium'),
(2, 3, 5, 18.0, 40, 350.00, 'High'),
(2, 3, 2, 18.0, 55, 220.00, 'Medium'),
(3, 4, 5, 20.0, 50, 400.00, 'High'),
(1, 5, 5, 12.0, 30, 250.00, 'High'),
(1, 5, 3, 12.0, 45, 40.00, 'Low');