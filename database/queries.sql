USE [sports_club-db];
GO

-- 1. Multi-table JOIN: Detailed list of court bookings
SELECT b.booking_id, m.first_name + ' ' + m.last_name AS member_name, 
       c.court_name, f.facility_name, b.booking_date, b.start_time, b.end_time
FROM court_bookings b
JOIN members m ON b.member_id = m.member_id
JOIN courts c ON b.court_id = c.court_id
JOIN facilities f ON c.facility_id = f.facility_id;

-- 2. Multi-table JOIN: Details of equipment loans
SELECT r.rental_id, m.first_name + ' ' + m.last_name AS member_name, 
       e.equipment_name, r.quantity, r.total_amount, r.rental_date
FROM equipment_rentals r
JOIN members m ON r.member_id = m.member_id
JOIN equipment e ON r.equipment_id = e.equipment_id;

-- 3. GROUP BY + HAVING: Find members whose total payment amount exceeds 500 THB
SELECT m.member_id, m.first_name, m.last_name, SUM(p.amount) AS total_paid
FROM members m
JOIN court_bookings cb ON m.member_id = cb.member_id
JOIN payments p ON cb.booking_id = p.booking_id
GROUP BY m.member_id, m.first_name, m.last_name
HAVING SUM(p.amount) > 500;

-- 4. GROUP BY + HAVING: Find courts that have been booked more than 3 times
SELECT c.court_id, c.court_name, COUNT(b.booking_id) AS total_bookings
FROM courts c
JOIN court_bookings b ON c.court_id = b.court_id
WHERE b.status = 'Confirmed'
GROUP BY c.court_id, c.court_name
HAVING COUNT(b.booking_id) > 3;

-- 5. GROUP BY + HAVING: Find locations where the total maintenance cost exceeds 1,000 THB
SELECT f.facility_id, f.facility_name, SUM(mt.cost) AS total_maint_cost
FROM facilities f
JOIN maintenance mt ON f.facility_id = mt.facility_id
GROUP BY f.facility_id, f.facility_name
HAVING SUM(mt.cost) > 1000;

-- 6. Subquery: Find members who have never made a court reservation
SELECT member_id, first_name, last_name, email
FROM members
WHERE member_id NOT IN (SELECT DISTINCT member_id FROM court_bookings);

-- 7. Subquery: Find equipment with a rental price higher than the average
SELECT equipment_name, rental_rate 
FROM equipment
WHERE rental_rate > (SELECT AVG(rental_rate) FROM equipment);

-- 8. Correlated Subquery: Find bookings with an amount higher than the average for that specific member
SELECT b1.booking_id, b1.member_id, b1.total_amount
FROM court_bookings b1
WHERE b1.total_amount >= (
    SELECT AVG(b2.total_amount)
    FROM court_bookings b2
    WHERE b2.member_id = b1.member_id
);

-- 9. Window Function: Rank the highest individual payment amounts
SELECT payment_id, member_id, amount,
       RANK() OVER (ORDER BY amount DESC) AS payment_rank
FROM payments p
LEFT JOIN court_bookings cb ON p.booking_id = cb.booking_id;

-- 10. Window Function: Calculate the cumulative total amount based on the order of booking dates
SELECT booking_id, member_id, booking_date, total_amount,
       SUM(total_amount) OVER(PARTITION BY member_id ORDER BY booking_date) AS running_total
FROM court_bookings;