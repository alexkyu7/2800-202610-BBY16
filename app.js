require("dotenv").config();

const express = require("express");
const session = require("express-session");
const bcrypt = require("bcrypt");
const Joi = require("joi");
const path = require("path");
const ejs = require("ejs");

const app = express();
const port = 3000;

app.set("view engine", "ejs");
app.use(express.static(path.join(__dirname, "public")));
// const { Client } = require("pg");

// async function main() {
//   const client = new Client({
//     user: process.env.DB_USER,
//     host: process.env.DB_HOST,
//     database: process.env.DB_NAME,
//     password: process.env.DB_PASSWORD,
//     port: process.env.DB_PORT,
//   });

//   await client.connect();
//   const res = await client.query("SELECT NOW()");
//   console.log(res.rows[0]);
//   await client.end();
// }

// main();

app.get("/", (req, res) => {
  res.render("homePagePreLogin", { title: "Foodle" });
});

app.get("/mainPage", (req, res) => {
  res.render("mainPage", { title: "Main Page" });
});

app.get("/searchPage", (req, res) => {
  res.render("searchPage", { title: "Search Services" });
});

app.get("/mapPage", (req, res) => {
  res.render("mapPage", { title: "Map View" });
});

app.get("/cartPage", (req, res) => {
  res.render("cartPage", { title: "Cart" });
});

app.get("/accountPage", (req, res) => {
  res.render("accountPage", { title: "Account" });
});

app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
