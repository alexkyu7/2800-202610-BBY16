const express = require('express');
const router = express.Router();

const pool = require('../db/connection');

// GET all users
router.get('/', async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT * FROM foodle_db.users ORDER BY id ASC`
        );

        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({
            error: 'Database error'
        });
    }
});

// POST create user
router.post('/', async (req, res) => {
    try {
        const {
            username,
            email,
            password_hash
        } = req.body;

        const result = await pool.query(
            `
            INSERT INTO foodle_db.users
            (username, email, password_hash)
            VALUES ($1, $2, $3)
            RETURNING *
            `,
            [username, email, password_hash]
        );

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({
            error: 'Database error'
        });
    }
});

module.exports = router;