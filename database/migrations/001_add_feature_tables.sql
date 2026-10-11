-- Migration 001: feature tables for recurring schedules, driver ratings, favourite locations.
-- Run against an existing cleantrack_uganda database: npm run db:migrate
-- Fresh setups do not need this file because database/schema.sql already includes these changes.

USE cleantrack_uganda;

-- Feature 3: favourite locations flag
ALTER TABLE customer_locations
  ADD COLUMN is_favourite TINYINT(1) NOT NULL DEFAULT 0 AFTER longitude;

-- Feature 1: recurring pickup schedules
CREATE TABLE IF NOT EXISTS pickup_schedules (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  location_id INT NOT NULL,
  waste_category_id INT NOT NULL,
  frequency ENUM('weekly', 'biweekly', 'monthly') NOT NULL,
  start_date DATE NOT NULL,
  next_run_date DATE NOT NULL,
  urgency ENUM('normal', 'urgent') NOT NULL DEFAULT 'normal',
  status ENUM('active', 'paused') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (location_id) REFERENCES customer_locations(id) ON DELETE CASCADE,
  FOREIGN KEY (waste_category_id) REFERENCES waste_categories(id)
);

-- Feature 2: driver ratings (one per pickup)
CREATE TABLE IF NOT EXISTS driver_ratings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  pickup_request_id INT NOT NULL UNIQUE,
  customer_id INT NOT NULL,
  driver_id INT NOT NULL,
  rating INT NOT NULL,
  comment TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (pickup_request_id) REFERENCES pickup_requests(id) ON DELETE CASCADE,
  FOREIGN KEY (customer_id) REFERENCES users(id),
  FOREIGN KEY (driver_id) REFERENCES users(id)
);
