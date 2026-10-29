const { poolPromise, sql } = require('../config/db');

// 1. ฟังก์ชันดึง/ค้นหารายชื่อสมาชิก
const getMembers = async (req, res) => {
  try {
    const { search } = req.query;
    const pool = await poolPromise;
    let query = 'SELECT * FROM members';

    if (search) {
      query += ` WHERE member_id LIKE @search OR first_name LIKE @search OR last_name LIKE @search`;
      const result = await pool.request()
        .input('search', sql.VarChar, `%${search}%`)
        .query(query);
      return res.json(result.recordset);
    }

    const result = await pool.request().query(query);
    res.json(result.recordset);
  } catch (error) {
    console.error('Error fetching members:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// 2. ฟังก์ชันเพิ่มสมาชิกใหม่
const createMember = async (req, res) => {
  try {
    const { member_id, first_name, last_name, phone, email, membership_type } = req.body;
    const pool = await poolPromise;

    await pool.request()
      .input('member_id', sql.VarChar, member_id)
      .input('first_name', sql.VarChar, first_name)
      .input('last_name', sql.VarChar, last_name)
      .input('phone', sql.VarChar, phone || null)
      .input('email', sql.VarChar, email || null)
      .input('membership_type', sql.VarChar, membership_type || 'Standard')
      .query(`
        INSERT INTO members (member_id, first_name, last_name, phone, email, membership_type)
        VALUES (@member_id, @first_name, @last_name, @phone, @email, @membership_type)
      `);

    res.status(201).json({ success: true, message: 'เพิ่มข้อมูลสมาชิกใหม่สำเร็จ!' });
  } catch (error) {
    console.error('Error creating member:', error);
    res.status(500).json({ success: false, error: error.message });
  }
};

module.exports = {
  getMembers,
  createMember
};