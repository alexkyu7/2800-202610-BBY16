const express = require('express');
const router = express.Router();

const pool = require('../db/connection');

// GET all services
router.get('/', async (req, res) => {
    try {
        const result = await pool.query(
            'SELECT * FROM foodle_db.services ORDER BY name ASC'
        );

        res.json(result.rows);
    } catch (err) {
        console.error(err);

        res.status(500).json({
            error: 'Database error'
        });
    }
});

// GET service by ID
router.get('/:id', async (req, res) => {
    try {
        const result = await pool.query(
            'SELECT * FROM foodle_db.services WHERE id = $1',
            [req.params.id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                error: 'Service not found'
            });
        }

        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);

        res.status(500).json({
            error: 'Database error'
        });
    }
});

// POST create new services
router.post('/', async (req, res) => {
    try {
        const {
            name,
            type,
            city,
            province
        } = req.body;

        const result = await pool.query(
            `
            INSERT INTO foodle_db.services
            (name, type, city, province)
            VALUES ($1, $2, $3, $4)
            RETURNING *
            `,
            [name, type, city, province]
        );

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({
            error: 'Database error'
        });
    }
});

// PUT update service
router.put('/:id', async (req, res) => {
    try {
        const {
            name,
            type,
            city,
            province
        } = req.body;

        const result = await pool.query(
            `
            UPDATE foodle_db.services
            SET
                name = $1,
                type = $2,
                city = $3,
                province = $4
            WHERE id = $5
            RETURNING *
            `,
            [name, type, city, province, req.params.id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                error: 'Service not found'
            });
        }

        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({
            error: 'Database error'
        });
    }
});

// DELETE service
router.delete('/:id', async (req, res) => {
    try {
        const result = await pool.query(
            `
            DELETE FROM foodle_db.services
            WHERE id = $1
            RETURNING *
            `,
            [req.params.id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                error: 'Service not found'
            });
        }

        res.json({
            message: 'Service deleted successfully'
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({
            error: 'Database error'
        });
    }
});

module.exports = router;