require("dotenv").config();

const express = require("express");
const session = require("express-session");
const bcrypt = require("bcrypt");
const Joi = require("joi");
const path = require("path");

const app = express();
const port = 3000;

import { Client } from "pg";

const client = new Client({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

await client.connect();
const res = await client.query("SELECT NOW()");
console.log(res.rows[0]);
await client.end();

app.get("/", (req, res) => {
  res.send("Hello, World! (stub)");
});

app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
