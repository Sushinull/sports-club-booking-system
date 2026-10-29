const express = require('express');
const cors = require('cors');
require('dotenv').config();

// นำเข้า Routes
const memberRoutes = require('./routes/memberRoutes');
const reportRoutes = require('./routes/reportRoutes');
const bookingRoutes = require('./routes/bookingRoutes');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors()); // อนุญาตให้ Frontend ดึงข้อมูลได้
app.use(express.json()); // อ่านข้อมูล JSON จาก Request body

// กำหนด API Endpoints
app.use('/api/members', memberRoutes);
app.use('/api/reports', reportRoutes);
app.use('/api/bookings', bookingRoutes);

// Test Route
app.get('/', (req, res) => {
  res.send('Sports Club API is running...');
});

// เริ่มต้นเปิด Server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});

