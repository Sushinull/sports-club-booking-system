const { poolPromise } = require('../config/db');

// ดึงข้อมูลรายงานจาก View ในฐานข้อมูล
exports.getFacilityUtilization = async (req, res) => {
  try {
    const pool = await poolPromise;
    
    // เปลี่ยนชื่อเป็น vw_FacilityUtilizationReport ตามที่มีใน SSMS
    const result = await pool.request().query('SELECT * FROM vw_FacilityUtilizationReport'); 

    res.json(result.recordset);
  } catch (error) {
    console.error('Error fetching report data:', error);
    res.status(500).json({ error: 'Server Error: ' + error.message });
  }
};