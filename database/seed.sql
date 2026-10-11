USE cleantrack_uganda;

-- All demo users use this password: password123
SET @demo_password = '$2b$10$1itDutuxh3pi2lmMrdAd4.7HOwRS0phpwopISzr5zTXSjScRatOZq';

INSERT INTO users (id, full_name, email, phone, password, role, status) VALUES
(1, 'CleanTrack Admin', 'admin@cleantrack.ug', '+256700000001', @demo_password, 'admin', 'active'),
(2, 'Amina Kato', 'manager@greenroute.ug', '+256700000002', @demo_password, 'manager', 'active'),
(3, 'Brian Okello', 'manager@kampalaclean.ug', '+256700000003', @demo_password, 'manager', 'active'),
(4, 'David Ssenyonga', 'driver1@cleantrack.ug', '+256700000004', @demo_password, 'driver', 'active'),
(5, 'Grace Namutebi', 'driver2@cleantrack.ug', '+256700000005', @demo_password, 'driver', 'active'),
(6, 'Isaac Mugisha', 'driver3@cleantrack.ug', '+256700000006', @demo_password, 'driver', 'active'),
(7, 'Joyce Akello', 'driver4@cleantrack.ug', '+256700000007', @demo_password, 'driver', 'active'),
(8, 'Sarah Nambi', 'customer@cleantrack.ug', '+256700000008', @demo_password, 'customer', 'active'),
(9, 'Peter Walusimbi', 'peter@example.com', '+256700000009', @demo_password, 'customer', 'active'),
(10, 'Ruth Atim', 'ruth@example.com', '+256700000010', @demo_password, 'customer', 'active'),
(11, 'Joseph Kiggundu', 'joseph@example.com', '+256700000011', @demo_password, 'customer', 'active'),
(12, 'Martha Nakato', 'martha@example.com', '+256700000012', @demo_password, 'customer', 'active'),
(13, 'Daniel Ouma', 'daniel@example.com', '+256700000013', @demo_password, 'customer', 'active');

INSERT INTO waste_companies (id, manager_id, company_name, phone, email, district, address, status) VALUES
(1, 2, 'GreenRoute Waste Services', '+256312111222', 'info@greenroute.ug', 'Kampala', 'Ntinda Industrial Area', 'active'),
(2, 3, 'Kampala Clean Collectors', '+256312333444', 'hello@kampalaclean.ug', 'Wakiso', 'Nansana Main Road', 'active');

INSERT INTO trucks (id, company_id, truck_number_plate, truck_capacity, driver_id, status) VALUES
(1, 1, 'UAK 123C', 4.50, 4, 'active'),
(2, 1, 'UBH 456D', 5.00, 5, 'active'),
(3, 1, 'UAZ 770K', 3.50, NULL, 'maintenance'),
(4, 2, 'UBJ 902L', 6.00, 6, 'active'),
(5, 2, 'UAY 333P', 4.00, 7, 'active');

INSERT INTO waste_categories (id, name, description, status) VALUES
(1, 'organic', 'Food remains, garden waste, and biodegradable material', 'active'),
(2, 'plastic', 'Plastic bottles, containers, and packaging', 'active'),
(3, 'paper', 'Paper, cartons, and cardboard', 'active'),
(4, 'metal', 'Metal cans and scrap metal', 'active'),
(5, 'glass', 'Glass bottles and broken glass', 'active'),
(6, 'mixed waste', 'Mixed household or business waste', 'active'),
(7, 'hazardous', 'Waste that requires special handling', 'active');

INSERT INTO customer_locations (id, user_id, location_name, location_type, district, division_or_subcounty, parish, village_or_zone, address_details, latitude, longitude) VALUES
(1, 8, 'Nambi Home', 'home', 'Kampala', 'Nakawa', 'Ntinda', 'Kiwatule', 'Near Kiwatule mosque', 0.36650000, 32.62680000),
(2, 8, 'Nambi Mini Market Stall', 'market_stall', 'Kampala', 'Central', 'Nakasero', 'Market Lane', 'Stall B22', 0.31560000, 32.58350000),
(3, 9, 'Walusimbi Hardware', 'business', 'Wakiso', 'Nansana', 'Nansana West', 'Nabweru', 'Opposite the taxi stage', 0.36320000, 32.52930000),
(4, 10, 'Atim Residence', 'home', 'Kampala', 'Makindye', 'Kansanga', 'Kiwafu', 'Blue gate on Church Road', 0.29140000, 32.61570000),
(5, 11, 'Kiggundu Primary School', 'school', 'Mukono', 'Goma', 'Seeta', 'Seeta', 'Behind Seeta trading center', 0.36390000, 32.74870000),
(6, 12, 'Nakato Clinic', 'institution', 'Kampala', 'Rubaga', 'Mengo', 'Lungujja', 'Clinic compound bins', 0.30690000, 32.55200000),
(7, 13, 'Ouma Apartments', 'business', 'Wakiso', 'Kira', 'Namugongo', 'Kyaliwajjala', 'Apartment block near main road', 0.39430000, 32.64570000);

INSERT INTO pickup_requests
(id, customer_id, location_id, waste_category_id, description, urgency, estimated_bin_level, status, requested_at, completed_at) VALUES
(1, 8, 1, 6, 'Household bin is overflowing after the weekend.', 'urgent', 95, 'pending', NOW() - INTERVAL 1 DAY, NULL),
(2, 8, 2, 2, 'Plastic bottles from the market stall.', 'normal', 70, 'assigned', NOW() - INTERVAL 2 DAY, NULL),
(3, 9, 3, 3, 'Cartons from hardware deliveries.', 'normal', 80, 'on_the_way', NOW() - INTERVAL 2 DAY, NULL),
(4, 10, 4, 1, 'Food waste from home compound.', 'urgent', 90, 'collected', NOW() - INTERVAL 7 DAY, NOW() - INTERVAL 6 DAY),
(5, 11, 5, 6, 'School bins full after sports day.', 'urgent', 100, 'failed', NOW() - INTERVAL 5 DAY, NOW() - INTERVAL 4 DAY),
(6, 12, 6, 7, 'Clinic hazardous waste ready for special pickup.', 'urgent', 85, 'pending', NOW() - INTERVAL 3 HOUR, NULL),
(7, 13, 7, 5, 'Glass waste from tenants.', 'normal', 65, 'pending', NOW() - INTERVAL 5 HOUR, NULL),
(8, 9, 3, 4, 'Metal scraps need collection.', 'normal', 60, 'assigned', NOW() - INTERVAL 4 DAY, NULL),
(9, 10, 4, 6, 'Mixed home waste.', 'normal', 75, 'collected', NOW() - INTERVAL 12 DAY, NOW() - INTERVAL 11 DAY),
(10, 11, 5, 3, 'Paper waste after exams.', 'normal', 55, 'pending', NOW() - INTERVAL 1 HOUR, NULL),
(11, 12, 6, 6, 'General clinic waste bin is full.', 'normal', 80, 'failed', NOW() - INTERVAL 10 DAY, NOW() - INTERVAL 9 DAY),
(12, 13, 7, 2, 'Plastic sacks from apartment tenants.', 'urgent', 88, 'collected', NOW() - INTERVAL 18 DAY, NOW() - INTERVAL 17 DAY);

INSERT INTO pickup_assignments
(id, pickup_request_id, company_id, truck_id, driver_id, assigned_by, status, collection_notes, failure_reason, waste_quantity_collected, assigned_at, completed_at) VALUES
(1, 2, 1, 1, 4, 2, 'assigned', NULL, NULL, NULL, NOW() - INTERVAL 1 DAY, NULL),
(2, 3, 1, 2, 5, 2, 'on_the_way', NULL, NULL, NULL, NOW() - INTERVAL 1 DAY, NULL),
(3, 4, 2, 4, 6, 3, 'collected', 'Collected two sacks of organic waste.', NULL, 42.50, NOW() - INTERVAL 7 DAY, NOW() - INTERVAL 6 DAY),
(4, 5, 2, 5, 7, 3, 'failed', NULL, 'School gate was locked when driver arrived.', NULL, NOW() - INTERVAL 5 DAY, NOW() - INTERVAL 4 DAY),
(5, 8, 1, 1, 4, 2, 'assigned', NULL, NULL, NULL, NOW() - INTERVAL 3 DAY, NULL),
(6, 9, 2, 4, 6, 3, 'collected', 'Collected mixed household waste.', NULL, 37.00, NOW() - INTERVAL 12 DAY, NOW() - INTERVAL 11 DAY),
(7, 11, 2, 5, 7, 3, 'failed', NULL, 'Waste was not sorted for safe collection.', NULL, NOW() - INTERVAL 10 DAY, NOW() - INTERVAL 9 DAY),
(8, 12, 1, 2, 5, 2, 'collected', 'Collected plastic sacks from apartment store.', NULL, 51.75, NOW() - INTERVAL 18 DAY, NOW() - INTERVAL 17 DAY);

INSERT INTO pickup_feedback (pickup_request_id, customer_id, rating, comment) VALUES
(4, 10, 5, 'The driver was polite and arrived early.'),
(9, 10, 4, 'Good service, but the pickup came later than expected.'),
(12, 13, 5, 'Very clean collection work.');

INSERT INTO notifications (user_id, title, message, status) VALUES
(8, 'Pickup received', 'Your pickup request has been received by CleanTrack Uganda.', 'unread'),
(4, 'New assignment', 'You have a new pickup assignment in Kampala.', 'unread'),
(2, 'Pending hazardous pickup', 'A hazardous pickup request needs assignment.', 'unread');

-- Feature 3 sample data: Sarah marks her home as a favourite location.
UPDATE customer_locations SET is_favourite = 1 WHERE id = 1;

-- Feature 2 sample data: customers rate drivers on their collected pickups.
INSERT INTO driver_ratings (pickup_request_id, customer_id, driver_id, rating, comment) VALUES
(4, 10, 6, 5, 'Isaac arrived early and kept the compound clean.'),
(9, 10, 6, 4, 'Good collection, but came later than expected.'),
(12, 13, 5, 5, 'Very professional plastic sorting help.');

-- Feature 1 sample data: weekly mixed-waste schedule for Sarah's home,
-- starting next Monday; the next four pickups are generated at runtime by the API.
INSERT INTO pickup_schedules (user_id, location_id, waste_category_id, frequency, start_date, next_run_date, urgency, status) VALUES
(8, 1, 6, 'weekly', CURDATE() + INTERVAL ((9 - WEEKDAY(CURDATE())) % 7) DAY,
 CURDATE() + INTERVAL ((9 - WEEKDAY(CURDATE())) % 7) DAY, 'normal', 'active');
