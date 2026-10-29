USE [sports_club-db];
GO

-- 1. Trigger: trg_CheckCourtConflict
IF OBJECT_ID('dbo.trg_CheckCourtConflict', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_CheckCourtConflict;
GO

CREATE TRIGGER trg_CheckCourtConflict
ON court_bookings
FOR INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM court_bookings b
        INNER JOIN inserted i ON b.court_id = i.court_id 
                             AND b.booking_date = i.booking_date
                             AND b.booking_id <> i.booking_id
        WHERE b.status = 'Confirmed'
          AND i.status = 'Confirmed'
          AND (
              (i.start_time >= b.start_time AND i.start_time < b.end_time) OR
              (i.end_time > b.start_time AND i.end_time <= b.end_time) OR
              (i.start_time <= b.start_time AND i.end_time >= b.end_time)
          )
    )
    BEGIN
        RAISERROR ('เกิดข้อผิดพลาด: สนามนี้ถูกจองในช่วงเวลาดังกล่าวไปแล้ว', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- 2. Stored Procedure: sp_BookCourtAndEquipment
IF OBJECT_ID('dbo.sp_BookCourtAndEquipment', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_BookCourtAndEquipment;
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
        BEGIN
            RAISERROR ('สนามไม่อยู่ในสถานะที่สามารถจองได้', 16, 1);
        END

        DECLARE @hourly_rate DECIMAL(10,2);
        DECLARE @hours DECIMAL(4,2);
        DECLARE @court_total DECIMAL(10,2);

        SELECT @hourly_rate = hourly_rate FROM courts WHERE court_id = @p_court_id;
        SET @hours = DATEDIFF(MINUTE, @p_start_time, @p_end_time) / 60.0;
        SET @court_total = @hourly_rate * @hours;

        INSERT INTO court_bookings (booking_id, member_id, court_id, booking_date, start_time, end_time, total_amount, hourly_rate_snapshot, status)
        VALUES (@p_booking_id, @p_member_id, @p_court_id, @p_booking_date, @p_start_time, @p_end_time, @court_total, @hourly_rate, 'Confirmed');

        INSERT INTO payments (payment_id, booking_id, amount, payment_method, status)
        VALUES (@p_payment_id_court, @p_booking_id, @court_total, @p_payment_method, 'Completed');

        IF @p_equipment_id IS NOT NULL AND @p_equip_quantity > 0 AND @p_rental_id IS NOT NULL
        BEGIN
            DECLARE @rental_rate DECIMAL(10,2);
            DECLARE @equip_total DECIMAL(10,2);

            SELECT @rental_rate = rental_rate FROM equipment WHERE equipment_id = @p_equipment_id;
            SET @equip_total = @rental_rate * @p_equip_quantity;

            INSERT INTO equipment_rentals (rental_id, member_id, equipment_id, rental_date, due_date, quantity, rental_rate_snapshot, total_amount, status)
            VALUES (@p_rental_id, @p_member_id, @p_equipment_id, @p_booking_date, @p_booking_date, @p_equip_quantity, @rental_rate, @equip_total, 'Active');

            INSERT INTO payments (payment_id, rental_id, amount, payment_method, status)
            VALUES (@p_payment_id_equip, @p_rental_id, @equip_total, @p_payment_method, 'Completed');
        END

        COMMIT TRANSACTION;
        PRINT 'ทำรายการจองและชำระเงินเรียบร้อยแล้ว';

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 3. Reporting View: vw_FacilityUtilizationReport
IF OBJECT_ID('dbo.vw_FacilityUtilizationReport', 'V') IS NOT NULL
    DROP VIEW dbo.vw_FacilityUtilizationReport;
GO

CREATE VIEW vw_FacilityUtilizationReport AS
SELECT 
    f.facility_name,
    f.facility_type,
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