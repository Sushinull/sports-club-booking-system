const express = require('express');
const router = express.Router();
const memberController = require('../controllers/memberController');

// GET /api/members
router.get('/', memberController.getMembers);

// POST /api/members
router.post('/', memberController.createMember);

module.exports = router;