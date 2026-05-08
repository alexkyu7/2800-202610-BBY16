const express = require('express');
const router = express.Router();

const pool = require('../db/connection');

// GET all categories
router.get('/', async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT * FROM foodle_db.service_categories ORDER BY name ASC`
        );

        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({
            error: 'Database error'
        });
    }
});

module.exports = router;