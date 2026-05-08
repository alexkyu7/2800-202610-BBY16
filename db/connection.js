// const { Pool } = require('pg');

// const pool = new Pool({
//     user: process.env.DB_USER,
//     host: process.env.DB_HOST,
//     database: process.env.DB_NAME,
//     password: process.env.DB_PASSWORD,
//     port: process.env.DB_PORT
// });

// pool.connect((err) => {
//     if (err) {
//         console.error('Database connection error:', err.stack);
//     } else {
//         console.log('Connected to PostgreSQL database');
//     }
// });

// module.exports = pool;

import postgres from "postgres";

const connectionString = process.env.DATABASE_URL;
const sql = postgres(connectionString);

sql.connect((err) => {
  if (err) {
    console.error("Database connection error:", err.stack);
  } else {
    console.log("Connected to PostgreSQL database");
  }
});

export default sql;
