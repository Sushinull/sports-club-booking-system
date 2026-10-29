const express = require('express');
const router = express.Router();
const reportController = require('../controllers/reportController');

// GET /api/reports/utilization
router.get('/utilization', reportController.getFacilityUtilization);

module.exports = router;