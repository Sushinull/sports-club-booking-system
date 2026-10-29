const { poolPromise, sql } = require('../config/db');

// ฟังก์ชันแปลงรูปแบบเวลาเป็น HH:mm:ss (24 ชม.)
function formatTo24Hour(timeStr) {
  if (!timeStr) return null;
  timeStr = timeStr.trim();

  const ampmMatch = timeStr.match(/^(\d{1,2}):(\d{2})\s*(AM|PM)$/i);
  if (ampmMatch) {
    let hours = parseInt(ampmMatch[1], 10);
    const minutes = ampmMatch[2];
    const period = ampmMatch[3].toUpperCase();

    if (period === 'PM' && hours < 12) hours += 12;
    if (period === 'AM' && hours === 12) hours = 0;

    const formattedHours = String(hours).padStart(2, '0');
    return `${formattedHours}:${minutes}:00`;
  }

  if (/^\d{1,2}:\d{2}$/.test(timeStr)) {
    const parts = timeStr.split(':');
    const hours = parts[0].padStart(2, '0');
    return `${hours}:${parts[1]}:00`;
  }

  return timeStr;
}

// สร้างรายการจองสนามและยืมอุปกรณ์
exports.createBooking = async (req, res) => {
  try {
    const {
      booking_id,
      member_id,
      court_id,
      booking_date,
      start_time,
      end_time,
      equipment_id,
      equip_quantity,
      rental_id
    } = req.body;

    const formattedStartTime = formatTo24Hour(start_time);
    const formattedEndTime = formatTo24Hour(end_time);

    const pool = await poolPromise;

    // 1. ตรวจสอบว่าสนามนี้ ในวันและช่วงเวลาดังกล่าว มีการจองไว้แล้วหรือยัง (Conflict Checking)
    const checkConflict = await pool.request()
      .input('court_id', sql.VarChar, court_id)
      .input('booking_date', sql.Date, booking_date)
      .input('start_time', sql.VarChar, formattedStartTime)
      .input('end_time', sql.VarChar, formattedEndTime)
      .query(`
        SELECT COUNT(*) AS count 
        FROM court_bookings 
        WHERE court_id = @court_id 
          AND booking_date = @booking_date 
          AND (
            (CAST(@start_time AS TIME) < end_time AND CAST(@end_time AS TIME) > start_time)
          )
      `);

    if (checkConflict.recordset[0].count > 0) {
      return res.status(400).json({ 
        success: false, 
        error: 'สนามนี้ถูกจองแล้วในช่วงเวลาดังกล่าว กรุณาเลือกช่วงเวลาหรือสนามอื่น' 
      });
    }

    // คำนวณชั่วโมงและยอดรวม
    const startHour = parseInt(formattedStartTime.split(':')[0], 10);
    const endHour = parseInt(formattedEndTime.split(':')[0], 10);
    const hoursBooked = Math.max(1, endHour - startHour);
    
    const hourlyRateSnapshot = 100.00;
    const totalCourtAmount = hoursBooked * hourlyRateSnapshot;

    // 2. บันทึกข้อมูลลงตาราง court_bookings
    await pool.request()
      .input('booking_id', sql.VarChar, booking_id)
      .input('member_id', sql.VarChar, member_id)
      .input('court_id', sql.VarChar, court_id)
      .input('booking_date', sql.Date, booking_date)
      .input('start_time', sql.VarChar, formattedStartTime)
      .input('end_time', sql.VarChar, formattedEndTime)
      .input('hourly_rate_snapshot', sql.Decimal(10, 2), hourlyRateSnapshot)
      .input('total_amount', sql.Decimal(10, 2), totalCourtAmount)
      .query(`
        INSERT INTO court_bookings (
          booking_id, member_id, court_id, booking_date, start_time, end_time, hourly_rate_snapshot, total_amount
        )
        VALUES (
          @booking_id, @member_id, @court_id, @booking_date, CAST(@start_time AS TIME), CAST(@end_time AS TIME), @hourly_rate_snapshot, @total_amount
        )
      `);

    // 3. บันทึกการยืมอุปกรณ์ลงตาราง equipment_rentals (หากมีการกรอกข้อมูล)
    if (equipment_id && equip_quantity > 0 && rental_id) {
      const equipFeeSnapshot = 50.00;
      const totalEquipAmount = equip_quantity * equipFeeSnapshot;

      await pool.request()
        .input('rental_id', sql.VarChar, rental_id)
        .input('member_id', sql.VarChar, member_id)
        .input('equipment_id', sql.VarChar, equipment_id)
        .input('quantity', sql.Int, equip_quantity)
        .input('total_amount', sql.Decimal(10, 2), totalEquipAmount)
        .input('rental_date', sql.Date, booking_date)
        .query(`
          INSERT INTO equipment_rentals (rental_id, member_id, equipment_id, quantity, total_amount, rental_date)
          VALUES (@rental_id, @member_id, @equipment_id, @quantity, @total_amount, @rental_date)
        `);
    }

    res.status(201).json({ success: true, message: 'ทำรายการจองสนามและยืมอุปกรณ์สำเร็จเรียบร้อย!' });
  } catch (error) {
    console.error('Error creating booking:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};