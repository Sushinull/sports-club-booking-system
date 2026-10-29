-- ===============================================================================
-- Database Initialization & Setup Script
-- Project: Sports Club & Facility Booking System
-- DBMS: Microsoft SQL Server 2025 / Azure SQL
-- ===============================================================================

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'sports_club-db')
BEGIN
    CREATE DATABASE [sports_club-db];
END
GO

USE [sports_club-db];
GO

-- -------------------------------------------------------------------------------
-- STEP 1: CLEANUP (Drop views, procedures, triggers, and tables)
-- -------------------------------------------------------------------------------
IF OBJECT_ID('dbo.vw_FacilityUtilizationReport', 'V') IS NOT NULL DROP VIEW dbo.vw_FacilityUtilizationReport;
IF OBJECT_ID('dbo.sp_BookCourtAndEquipment', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_BookCourtAndEquipment;

IF OBJECT_ID('dbo.payments', 'U') IS NOT NULL DROP TABLE dbo.payments;
IF OBJECT_ID('dbo.equipment_rentals', 'U') IS NOT NULL DROP TABLE dbo.equipment_rentals;
IF OBJECT_ID('dbo.court_bookings', 'U') IS NOT NULL DROP TABLE dbo.court_bookings;
IF OBJECT_ID('dbo.maintenance', 'U') IS NOT NULL DROP TABLE dbo.maintenance;
IF OBJECT_ID('dbo.equipment', 'U') IS NOT NULL DROP TABLE dbo.equipment;
IF OBJECT_ID('dbo.courts', 'U') IS NOT NULL DROP TABLE dbo.courts;
IF OBJECT_ID('dbo.members', 'U') IS NOT NULL DROP TABLE dbo.members;
IF OBJECT_ID('dbo.facilities', 'U') IS NOT NULL DROP TABLE dbo.facilities;
IF OBJECT_ID('dbo.staff', 'U') IS NOT NULL DROP TABLE dbo.staff;
GO

-- -------------------------------------------------------------------------------
-- STEP 2: CREATE TABLES & CONSTRAINTS
-- -------------------------------------------------------------------------------
CREATE TABLE staff (
    staff_id VARCHAR(10) PRIMARY KEY,
    first_name NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255) UNIQUE NOT NULL,
    position NVARCHAR(50) NOT NULL,
    status NVARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE facilities (
    facility_id VARCHAR(10) PRIMARY KEY,
    facility_name NVARCHAR(100) NOT NULL,
    facility_type NVARCHAR(50) NOT NULL,
    location NVARCHAR(150),
    opening_time TIME(0),
    closing_time TIME(0),
    status NVARCHAR(20) DEFAULT 'Active'
);

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

CREATE TABLE courts (
    court_id VARCHAR(10) PRIMARY KEY,
    facility_id VARCHAR(10) NOT NULL,
    court_name NVARCHAR(100) NOT NULL,
    court_type NVARCHAR(50),
    capacity INT CHECK (capacity >= 0),
    hourly_rate DECIMAL(10,2) NOT NULL CHECK (hourly_rate >= 0),
    status NVARCHAR(20) DEFAULT 'Available',
    CONSTRAINT fk_courts_facility FOREIGN KEY (facility_id) REFERENCES facilities(facility_id) ON DELETE CASCADE
);

CREATE TABLE equipment (
    equipment_id VARCHAR(10) PRIMARY KEY,
    equipment_name NVARCHAR(100) NOT NULL,
    equipment_type NVARCHAR(50),
    total_quantity INT NOT NULL CHECK (total_quantity >= 0),
    rental_rate DECIMAL(10,2) NOT NULL CHECK (rental_rate >= 0),
    status NVARCHAR(20) DEFAULT 'Available'
);

CREATE TABLE maintenance (
    maintenance_id VARCHAR(10) PRIMARY KEY,
    staff_id VARCHAR(10) NOT NULL,
    facility_id VARCHAR(10) NULL,
    court_id VARCHAR(10) NULL,
    equipment_id VARCHAR(10) NULL,
    maintenance_date DATE NOT NULL,
    description NVARCHAR(500) NOT NULL,
    cost DECIMAL(10,2) DEFAULT 0.00 CHECK (cost >= 0),
    status NVARCHAR(20) DEFAULT 'Completed',
    CONSTRAINT fk_maint_staff FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    CONSTRAINT fk_maint_facility FOREIGN KEY (facility_id) REFERENCES facilities(facility_id),
    CONSTRAINT fk_maint_court FOREIGN KEY (court_id) REFERENCES courts(court_id),
    CONSTRAINT fk_maint_equipment FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id)
);

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
    CONSTRAINT fk_bookings_member FOREIGN KEY (member_id) REFERENCES members(member_id),
    CONSTRAINT fk_bookings_court FOREIGN KEY (court_id) REFERENCES courts(court_id),
    CONSTRAINT chk_booking_time CHECK (end_time > start_time)
);

CREATE TABLE equipment_rentals (
    rental_id VARCHAR(10) PRIMARY KEY,
    member_id VARCHAR(10) NOT NULL,
    equipment_id VARCHAR(10) NOT NULL,
    rental_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    rental_rate_snapshot DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    status NVARCHAR(20) DEFAULT 'Active',
    CONSTRAINT fk_rentals_member FOREIGN KEY (member_id) REFERENCES members(member_id),
    CONSTRAINT fk_rentals_equipment FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id)
);

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

CREATE INDEX idx_bookings_court_date ON court_bookings(court_id, booking_date, start_time, end_time);
CREATE INDEX idx_members_email ON members(email);
GO

-- -------------------------------------------------------------------------------
-- STEP 3: LOGIC (TRIGGERS, PROCEDURES, VIEWS)
-- -------------------------------------------------------------------------------
CREATE TRIGGER trg_CheckCourtConflict
ON court_bookings FOR INSERT, UPDATE AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM court_bookings b
        INNER JOIN inserted i ON b.court_id = i.court_id 
                             AND b.booking_date = i.booking_date
                             AND b.booking_id <> i.booking_id
        WHERE b.status = 'Confirmed' AND i.status = 'Confirmed'
          AND ((i.start_time >= b.start_time AND i.start_time < b.end_time) 
            OR (i.end_time > b.start_time AND i.end_time <= b.end_time) 
            OR (i.start_time <= b.start_time AND i.end_time >= b.end_time))
    )
    BEGIN
        RAISERROR ('Conflict Detected: Court is already booked for this timeslot.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

CREATE PROCEDURE sp_BookCourtAndEquipment
    @p_booking_id VARCHAR(10),
    @p_rental_id VARCHAR(10) = NULL,
    @p_payment_id_court VARCHAR(10),
    @p_payment_id_equip VARCHAR(10) = NULL,
    @p_member_id VARCHAR(10),
    @p_court_id VARCHAR(10),
    @p_booking_date DATE,
    @p_start_time TIME(0),
    @p_end_time TIME(0),
    @p_equipment_id VARCHAR(10) = NULL,
    @p_equip_quantity INT = 0,
    @p_payment_method NVARCHAR(30) = 'Credit Card'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM courts WHERE court_id = @p_court_id AND status = 'Available')
            RAISERROR ('Court unavailable', 16, 1);

        DECLARE @hourly_rate DECIMAL(10,2), @hours DECIMAL(4,2), @court_total DECIMAL(10,2);
        SELECT @hourly_rate = hourly_rate FROM courts WHERE court_id = @p_court_id;
        SET @hours = DATEDIFF(MINUTE, @p_start_time, @p_end_time) / 60.0;
        SET @court_total = @hourly_rate * @hours;

        INSERT INTO court_bookings (booking_id, member_id, court_id, booking_date, start_time, end_time, total_amount, hourly_rate_snapshot, status)
        VALUES (@p_booking_id, @p_member_id, @p_court_id, @p_booking_date, @p_start_time, @p_end_time, @court_total, @hourly_rate, 'Confirmed');

        INSERT INTO payments (payment_id, booking_id, amount, payment_method, status)
        VALUES (@p_payment_id_court, @p_booking_id, @court_total, @p_payment_method, 'Completed');

        IF @p_equipment_id IS NOT NULL AND @p_equip_quantity > 0 AND @p_rental_id IS NOT NULL
        BEGIN
            DECLARE @rental_rate DECIMAL(10,2), @equip_total DECIMAL(10,2);
            SELECT @rental_rate = rental_rate FROM equipment WHERE equipment_id = @p_equipment_id;
            SET @equip_total = @rental_rate * @p_equip_quantity;

            INSERT INTO equipment_rentals (rental_id, member_id, equipment_id, rental_date, due_date, quantity, rental_rate_snapshot, total_amount, status)
            VALUES (@p_rental_id, @p_member_id, @p_equipment_id, @p_booking_date, @p_booking_date, @p_equip_quantity, @rental_rate, @equip_total, 'Active');

            INSERT INTO payments (payment_id, rental_id, amount, payment_method, status)
            VALUES (@p_payment_id_equip, @p_rental_id, @equip_total, @p_payment_method, 'Completed');
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE VIEW vw_FacilityUtilizationReport AS
SELECT 
    f.facility_name, f.facility_type,
    DATEPART(YEAR, cb.booking_date) AS booking_year,
    DATEPART(WEEK, cb.booking_date) AS booking_week,
    COUNT(DISTINCT cb.booking_id) AS total_court_bookings,
    SUM(DATEDIFF(MINUTE, cb.start_time, cb.end_time) / 60.0) AS total_hours_booked,
    SUM(cb.total_amount) AS total_court_revenue
FROM facilities f
JOIN courts c ON f.facility_id = c.facility_id
JOIN court_bookings cb ON c.court_id = cb.court_id
WHERE cb.status = 'Confirmed'
GROUP BY f.facility_name, f.facility_type, DATEPART(YEAR, cb.booking_date), DATEPART(WEEK, cb.booking_date);
GO