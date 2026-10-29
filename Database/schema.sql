-- 1. Staff
CREATE TABLE staff (
	staff_id VARCHAR(10) PRIMARY KEY,
	first_name NVARCHAR(50) NOT NULL,
	last_name NVARCHAR(50) NOT NULL,
	phone VARCHAR(20),
	email VARCHAR(255) UNIQUE NOT NULL,
	position NVARCHAR(50),
	status NVARCHAR(20)
);

-- 2. Facilities
CREATE TABLE facilities (
	facility_id VARCHAR(10) PRIMARY KEY,
	facility_name NVARCHAR(100) NOT NULL,
	facility_type NVARCHAR(50) NOT NULL,
	location NVARCHAR(150),
	opening_time TIME(0),
	closing_time TIME(0),
	status NVARCHAR(20) DEFAULT 'Active'
);

-- 3. Members
CREATE TABLE members (
	member_id VARCHAR(10) PRIMARY KEY,
	first_name NVARCHAR(50) NOT NULL,
	last_name NVARCHAR(50) NOT NULL,
	phone VARCHAR(20),
	email VARCHAR(255) UNIQUE NOT NULL,
	membership_type NVARCHAR(50) DEFAULT 'Standard',
	membership_start DATE,
	membership_end DATE,
	status NVARCHAR(20) DEFAULT 'Active'
);

-- 4. Courts
CREATE TABLE courts (
	court_id VARCHAR(10) PRIMARY KEY,
	facility_id VARCHAR(10) NOT NULL,
	court_name NVARCHAR(100) NOT NULL,
	court_type NVARCHAR(50),
	capacity INT CHECK (capacity >= 0),
	hourly_rate DECIMAL(10,2) NOT NULL CHECK (hourly_rate >= 0),
	status NVARCHAR(20) DEFAULT 'Available',
	CONSTRAINT fk_courts_facility FOREIGN KEY (facility_id) REFERENCES facilities(facility_id)
);

-- 5. Equipment
CREATE TABLE equipment (
	equipment_id VARCHAR(10) PRIMARY KEY,
	equipment_name NVARCHAR(100) NOT NULL,
	equipment_type NVARCHAR(50),
	total_quantity INT NOT NULL CHECK (total_quantity >= 0),
	rental_rate DECIMAL(10,2) NOT NULL CHECK (rental_rate >= 0),
	status NVARCHAR(20) DEFAULT 'Available'
);

-- 6. Maintenace
CREATE TABLE maintenance (
	maintenance_id VARCHAR(10) PRIMARY KEY,
	staff_id VARCHAR(10) NOT NULL,
	facility_id VARCHAR(10) NULL,
	court_id VARCHAR(10) NULL,
	equipment_id VARCHAR(10) NULL,
	maintenance_date DATE NOT NULL,
	description NVARCHAR(500),
	cost DECIMAL(10,2) DEFAULT 0.00 CHECK (cost >= 0),
	status NVARCHAR(20) DEFAULT 'Completed',
	CONSTRAINT fk_maint_staff FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
	CONSTRAINT fk_maint_facility  FOREIGN KEY (facility_id) REFERENCES facilities(facility_id),
	CONSTRAINT fk_maint_court FOREIGN KEY (court_id) ReFERENCES courts(court_id),
	CONSTRAINT fk_maint_equipment FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id) 
);

-- 7. Court Booking
CREATE TABLE court_bookings (
	booking_id VARCHAR(10) PRIMARY KEY,
	member_id VARCHAR(10) NOT NULL,
	court_id VARCHAR(10) NOT NULL,
	booking_date DATE NOT NULL,
	start_time TIME(0) NOT NULL,
	end_time TIME(0) NOT NULL,
	total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
	hourly_rate_snapshot DECIMAL(10,2) NOT NULL,
	status NVARCHAR(20) DEFAULT 'Confirmed',
	created_at DATETIME2(0) DEFAULT GETDATE(),
	CONSTRAINT fk_booking_member FOREIGN KEY (member_id) REFERENCES members(member_id),
	CONSTRAINT fk_booking_court FOREIGN KEY (court_id) REFERENCES courts(court_id),
	CONSTRAINT chk_booking_time CHECK (end_time > start_time)
);

-- 8. Equipment Rentals
CREATE TABLE equipment_rentals (
	rental_id VARCHAR(10) PRIMARY KEY,
	member_id VARCHAR(10) NOT NULL,
	equipment_id VARCHAR(10) NOT NULL,
	rental_date DATE NOT NULL,
	due_date DATE NOT NULL,
	return_date DATE  NULL,
	quantity INT NOT NULL CHECK (quantity > 0),
	rental_rate_snapshot DECIMAL(10,2) NOT NULL,
	total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
	status NVARCHAR(20) DEFAULT 'Active'
	CONSTRAINT fk_rentals_member FOREIGN KEY (member_id) REFERENCES members(member_id),
	CONSTRAINT fk_rentals_equipment FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id)
);

-- 9. Payments
CREATE TABLE payments (
	payment_id VARCHAR(10) PRIMARY KEY,
	rental_id VARCHAR(10) NULL,
	booking_id VARCHAR(10) NULL,
	amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
	payment_date DATETIME2(0) DEFAULT GETDATE(),
	payment_method NVARCHAR(30) NOT NULL,
	transaction_ref VARCHAR(100) NULL,
	status NVARCHAR(20) DEFAULT 'Completed',
	CONSTRAINT fk_payments_rental FOREIGN KEY (rental_id) REFERENCES equipment_rentals(rental_id),
	CONSTRAINT fk_payments_booking FOREIGN KEY (booking_id) REFERENCES court_bookings(booking_id)	
);

-- Indexes for performance optimization
CREATE INDEX idx_bookings_court_date ON court_bookings(court_id, booking_date, start_time, end_time);
CREATE INDEX idx_members_email ON members(email);