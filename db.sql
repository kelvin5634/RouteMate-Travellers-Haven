-- Create database
CREATE DATABASE IF NOT EXISTS transport_management;
USE transport_management;

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('admin', 'passenger') NOT NULL DEFAULT 'passenger',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Routes table
CREATE TABLE IF NOT EXISTS routes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  origin VARCHAR(100) NOT NULL,
  destination VARCHAR(100) NOT NULL,
  distance DECIMAL(10, 2),
  duration INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Vehicles table
CREATE TABLE IF NOT EXISTS vehicles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  registration_number VARCHAR(20) NOT NULL UNIQUE,
  capacity INT NOT NULL,
  route_id INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE SET NULL
);

-- Schedules table
CREATE TABLE IF NOT EXISTS schedules (
  id INT AUTO_INCREMENT PRIMARY KEY,
  route_id INT NOT NULL,
  vehicle_id INT NOT NULL,
  departure_time DATETIME NOT NULL,
  arrival_time DATETIME NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
);

-- Bookings table
CREATE TABLE IF NOT EXISTS bookings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  schedule_id INT NOT NULL,
  seat_number INT NOT NULL,
  booking_reference VARCHAR(20) NOT NULL UNIQUE,
  status ENUM('pending', 'confirmed', 'cancelled') NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (schedule_id) REFERENCES schedules(id) ON DELETE CASCADE,
  UNIQUE KEY (schedule_id, seat_number)
);

-- Contact messages table
CREATE TABLE IF NOT EXISTS contact_messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  subject VARCHAR(200) NOT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert admin user
INSERT INTO users (name, email, password, role) VALUES 
('Admin User', 'admin@transport.com', '$2b$10$JK5SJ2.8zFQbWRmfzxZVDuHCJYif.B7tSuqKPg2qM.iuG.6oNM1vy', 'admin');
-- Password is 'admin123'

-- Insert sample routes
INSERT INTO routes (origin, destination, distance, duration) VALUES
('New York', 'Boston', 215.4, 240),
('Chicago', 'Detroit', 283.1, 300),
('Los Angeles', 'San Francisco', 383.0, 360),
('Miami', 'Orlando', 235.6, 210),
('Seattle', 'Portland', 174.2, 180),
('Dallas', 'Houston', 239.8, 210);

-- Insert sample vehicles
INSERT INTO vehicles (name, registration_number, capacity, route_id) VALUES
('Express Bus 1', 'XB-1234', 45, 1),
('City Liner', 'CL-5678', 50, 2),
('Coastal Express', 'CE-9012', 40, 3),
('Sunshine Shuttle', 'SS-3456', 35, 4),
('Northwest Transit', 'NT-7890', 48, 5),
('Texas Cruiser', 'TC-1357', 42, 6);

-- Insert sample schedules
INSERT INTO schedules (route_id, vehicle_id, departure_time, arrival_time, price) VALUES
(1, 1, '2023-06-01 08:00:00', '2023-06-01 12:00:00', 45.99),
(2, 2, '2023-06-01 09:30:00', '2023-06-01 14:30:00', 52.50),
(3, 3, '2023-06-01 07:15:00', '2023-06-01 13:15:00', 65.75),
(4, 4, '2023-06-01 10:00:00', '2023-06-01 13:30:00', 38.25),
(5, 5, '2023-06-01 08:45:00', '2023-06-01 11:45:00', 29.99),
(6, 6, '2023-06-01 11:30:00', '2023-06-01 15:00:00', 42.00);
