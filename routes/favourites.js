const express = require('express');
const router = express.Router();

const pool = require('../db/connection');

// GET all favourites for a user
router.get('/:userId', async (req, res) => {
    try {
        const result = await pool.query(
            `
            SELECT s.*
            FROM foodle_db.user_favorites uf
            JOIN foodle_db.services s
            ON uf.service_id = s.id
            WHERE uf.user_id = $1
            `,
            [req.params.userId]
        );

        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({
            error: 'Database error'
        });
    }
});

// POST add favourite
router.post('/', async (req, res) => {
    try {
        const {
            user_id,
            service_id
        } = req.body;

        const result = await pool.query(
            `
            INSERT INTO foodle_db.user_favorites
            (user_id, service_id)
            VALUES ($1, $2)
            RETURNING *
            `,
            [user_id, service_id]
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