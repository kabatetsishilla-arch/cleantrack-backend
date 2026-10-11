DROP DATABASE IF EXISTS cleantrack_uganda;
CREATE DATABASE cleantrack_uganda;
USE cleantrack_uganda;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  phone VARCHAR(30),
  password VARCHAR(255) NOT NULL,
  role ENUM('admin', 'customer', 'driver', 'manager') NOT NULL DEFAULT 'customer',
  status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE customer_locations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  location_name VARCHAR(120) NOT NULL,
  location_type ENUM('home', 'business', 'school', 'market_stall', 'institution') NOT NULL,
  district VARCHAR(80) NOT NULL,
  division_or_subcounty VARCHAR(80),
  parish VARCHAR(80),
  village_or_zone VARCHAR(80),
  address_details TEXT,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  is_favourite TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE waste_companies (
  id INT AUTO_INCREMENT PRIMARY KEY,
  manager_id INT NOT NULL,
  company_name VARCHAR(150) NOT NULL,
  phone VARCHAR(30),
  email VARCHAR(120),
  district VARCHAR(80) NOT NULL,
  address TEXT,
  status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (manager_id) REFERENCES users(id)
);

CREATE TABLE trucks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  company_id INT NOT NULL,
  truck_number_plate VARCHAR(40) NOT NULL UNIQUE,
  truck_capacity DECIMAL(10, 2),
  driver_id INT,
  status ENUM('active', 'maintenance', 'inactive') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (company_id) REFERENCES waste_companies(id) ON DELETE CASCADE,
  FOREIGN KEY (driver_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE waste_categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80) NOT NULL UNIQUE,
  description TEXT,
  status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE pickup_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  location_id INT NOT NULL,
  waste_category_id INT NOT NULL,
  description TEXT,
  photo VARCHAR(255),
  urgency ENUM('normal', 'urgent') NOT NULL DEFAULT 'normal',
  estimated_bin_level INT NOT NULL,
  status ENUM('pending', 'assigned', 'on_the_way', 'collected', 'failed', 'cancelled') NOT NULL DEFAULT 'pending',
  requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES users(id),
  FOREIGN KEY (location_id) REFERENCES customer_locations(id),
  FOREIGN KEY (waste_category_id) REFERENCES waste_categories(id)
);

CREATE TABLE pickup_assignments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  pickup_request_id INT NOT NULL,
  company_id INT NOT NULL,
  truck_id INT NOT NULL,
  driver_id INT NOT NULL,
  assigned_by INT NOT NULL,
  status ENUM('assigned', 'on_the_way', 'collected', 'failed') NOT NULL DEFAULT 'assigned',
  collection_notes TEXT,
  failure_reason TEXT,
  waste_quantity_collected DECIMAL(10, 2),
  proof_photo VARCHAR(255),
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (pickup_request_id) REFERENCES pickup_requests(id) ON DELETE CASCADE,
  FOREIGN KEY (company_id) REFERENCES waste_companies(id),
  FOREIGN KEY (truck_id) REFERENCES trucks(id),
  FOREIGN KEY (driver_id) REFERENCES users(id),
  FOREIGN KEY (assigned_by) REFERENCES users(id)
);

CREATE TABLE pickup_feedback (
  id INT AUTO_INCREMENT PRIMARY KEY,
  pickup_request_id INT NOT NULL,
  customer_id INT NOT NULL,
  rating INT NOT NULL,
  comment TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (pickup_request_id) REFERENCES pickup_requests(id) ON DELETE CASCADE,
  FOREIGN KEY (customer_id) REFERENCES users(id)
);

CREATE TABLE pickup_schedules (
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

CREATE TABLE driver_ratings (
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

CREATE TABLE notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(120) NOT NULL,
  message TEXT NOT NULL,
  status ENUM('unread', 'read') NOT NULL DEFAULT 'unread',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  read_at TIMESTAMP NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE audit_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  action VARCHAR(120) NOT NULL,
  details TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);
