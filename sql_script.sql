-- =============================================
-- Vehicle Rental System
-- Student: Muzamil Waheed
-- Roll No: 22P-9419
-- =============================================

-- Database banana
CREATE DATABASE vehicle_rental;
USE vehicle_rental;

-- =============================================
-- TABLE 1: Categories
-- =============================================
CREATE TABLE categories (
    category_id   INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    description   TEXT
);

-- =============================================
-- TABLE 2: Users
-- =============================================
CREATE TABLE users (
    user_id    INT AUTO_INCREMENT PRIMARY KEY,
    full_name  VARCHAR(100) NOT NULL,
    email      VARCHAR(100) NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    phone      VARCHAR(20),
    role       ENUM('admin','customer') DEFAULT 'customer',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- TABLE 3: Vehicles
-- =============================================
CREATE TABLE vehicles (
    vehicle_id    INT AUTO_INCREMENT PRIMARY KEY,
    category_id   INT NOT NULL,
    make          VARCHAR(50) NOT NULL,
    model         VARCHAR(50) NOT NULL,
    year          INT NOT NULL,
    license_plate VARCHAR(20) NOT NULL UNIQUE,
    daily_rate    DECIMAL(10,2) NOT NULL,
    status        ENUM('available','rented','maintenance') DEFAULT 'available',
    image_url     VARCHAR(255),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- =============================================
-- TABLE 4: Bookings
-- =============================================
CREATE TABLE bookings (
    booking_id   INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT NOT NULL,
    vehicle_id   INT NOT NULL,
    start_date   DATE NOT NULL,
    end_date     DATE NOT NULL,
    total_days   INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status       ENUM('pending','confirmed','completed','cancelled') DEFAULT 'pending',
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)    REFERENCES users(user_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id)
);

-- =============================================
-- TABLE 5: Payments
-- =============================================
CREATE TABLE payments (
    payment_id     INT AUTO_INCREMENT PRIMARY KEY,
    booking_id     INT NOT NULL,
    amount         DECIMAL(10,2) NOT NULL,
    payment_date   DATE NOT NULL,
    payment_method ENUM('cash','card') DEFAULT 'cash',
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- =============================================
-- SAMPLE DATA
-- =============================================

INSERT INTO categories (category_name, description) VALUES
('Car',  'Standard passenger cars'),
('Van',  'Large vans for groups'),
('Bike', 'Motorcycles and scooters');

INSERT INTO users (full_name, email, password, phone, role) VALUES
('Admin User', 'admin@rental.com', 'admin123', '03001234567', 'admin'),
('Ali Khan',   'ali@gmail.com',   'ali123',   '03111234567', 'customer'),
('Sara Ahmed', 'sara@gmail.com',  'sara123',  '03211234567', 'customer');

INSERT INTO vehicles 
(category_id, make, model, year, license_plate, daily_rate, status) VALUES
(1, 'Toyota', 'Corolla', 2022, 'ABC-123', 5000.00, 'available'),
(1, 'Honda',  'Civic',   2021, 'XYZ-456', 6000.00, 'available'),
(2, 'Toyota', 'Hiace',   2020, 'VAN-789', 8000.00, 'rented'),
(3, 'Yamaha', 'YBR125',  2023, 'BIK-321', 1500.00, 'available');

INSERT INTO bookings 
(user_id, vehicle_id, start_date, end_date, total_days, total_amount, status) VALUES
(2, 1, '2024-01-01', '2024-01-03', 3, 15000.00, 'completed'),
(3, 3, '2024-01-05', '2024-01-07', 2, 16000.00, 'confirmed');

INSERT INTO payments 
(booking_id, amount, payment_date, payment_method) VALUES
(1, 15000.00, '2024-01-01', 'cash'),
(2, 16000.00, '2024-01-05', 'card');

-- =============================================
-- UPDATE & DELETE
-- =============================================

-- Vehicle status update karna
UPDATE vehicles SET status = 'rented' WHERE vehicle_id = 1;

-- Booking cancel karna
-- (pehle payment delete karni hogi)
DELETE FROM payments WHERE booking_id = 1;
DELETE FROM bookings WHERE booking_id = 1;

-- =============================================
-- JOINS
-- =============================================

-- Booking details with customer and vehicle
SELECT 
    b.booking_id,
    u.full_name   AS customer_name,
    v.make, 
    v.model,
    b.start_date, 
    b.end_date,
    b.total_amount,
    b.status
FROM bookings b
JOIN users    u ON b.user_id    = u.user_id
JOIN vehicles v ON b.vehicle_id = v.vehicle_id;

-- Left Join — sab users, booking ho ya na ho
SELECT 
    u.full_name,
    b.booking_id,
    b.total_amount
FROM users u
LEFT JOIN bookings b ON u.user_id = b.user_id;

-- =============================================
-- SUBQUERIES
-- =============================================

-- Jo vehicles kabhi book nahi hue
SELECT make, model 
FROM vehicles
WHERE vehicle_id NOT IN (
    SELECT vehicle_id FROM bookings
);

-- Jo customers average se zyada kharch kar chuke hain
SELECT full_name FROM users
WHERE user_id IN (
    SELECT user_id FROM bookings
    WHERE total_amount > (
        SELECT AVG(total_amount) FROM bookings
    )
);

-- =============================================
-- VIEW
-- =============================================

CREATE VIEW booking_details AS
SELECT 
    b.booking_id,
    u.full_name  AS customer,
    v.make, 
    v.model,
    b.start_date,
    b.end_date,
    b.total_amount,
    b.status
FROM bookings b
JOIN users    u ON b.user_id    = u.user_id
JOIN vehicles v ON b.vehicle_id = v.vehicle_id;

-- View use karna
SELECT * FROM booking_details;

-- =============================================
-- INDEXES
-- =============================================

CREATE INDEX idx_email  ON users(email);
CREATE INDEX idx_status ON vehicles(status);
CREATE INDEX idx_dates  ON bookings(start_date, end_date);

-- =============================================
-- AGGREGATE FUNCTIONS — REPORTS
-- =============================================

-- Total revenue
SELECT SUM(total_amount) AS total_revenue FROM bookings;

-- Average booking amount
SELECT AVG(total_amount) AS avg_booking FROM bookings;

-- Revenue by category
SELECT 
    c.category_name,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_amount) AS total_revenue,
    AVG(b.total_amount) AS avg_revenue
FROM categories c
JOIN vehicles v ON c.category_id = v.category_id
JOIN bookings b ON v.vehicle_id  = b.vehicle_id
GROUP BY c.category_id;

-- Most booked vehicles
SELECT 
    CONCAT(v.make,' ',v.model) AS vehicle_name,
    COUNT(b.booking_id)        AS total_bookings,
    SUM(b.total_amount)        AS total_revenue
FROM vehicles v
JOIN bookings b ON v.vehicle_id = b.vehicle_id
GROUP BY v.vehicle_id
ORDER BY total_bookings DESC;