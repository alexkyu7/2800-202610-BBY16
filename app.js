require("dotenv").config();

const express = require("express");
const session = require("express-session");
const bcrypt = require("bcrypt");
const Joi = require("joi");
const path = require("path");
const ejs = require("ejs");

// TODO: Replace with your PostgreSQL client import
// e.g. const { Pool } = require("pg");
// const POSTGRES_CLIENT = null;

const app = express();
const port = 3000;
const saltRounds = 12;

// session expiry is 1 hour
const expireTime = 1 * 60 * 60 * 1000;

app.set("trust proxy", 1);

app.set("view engine", "ejs");

// middleware
app.use(express.urlencoded({ extended: false }));
app.use(express.static(path.join(__dirname, "public")));

app.use(
  session({
    secret: process.env.NODE_SESSION_SECRET,
    resave: false,
    saveUninitialized: false,

    // TODO: Replace with a PostgreSQL-compatible session store
    // e.g. connect-pg-simple: const pgSession = require("connect-pg-simple")(session);
    // store: new pgSession({ pool: POSTGRES_CLIENT, tableName: "POSTGRES_SESSIONS_TABLE" })
    // store: "POSTGRES_SESSION_STORE",

    cookie: {
      maxAge: expireTime,
      secure: process.env.NODE_ENV === "production",
      sameSite: process.env.NODE_ENV === "production" ? "none" : "lax",
    },
  }),
);

// helper
function isLoggedIn(req) {
  return req.session && req.session.authenticated;
}

// routes

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

app.get("/foodBanks", (req, res) => {
  res.render("foodBanks", { title: "Food Banks" });
});

app.get("/communityFridges", (req, res) => {
  res.render("communityFridges", { title: "Community Fridges" });
});

app.get("/mealPrograms", (req, res) => {
  res.render("mealPrograms", { title: "Meal Programs" });
});

app.get("/foodRecycling", (req, res) => {
  res.render("foodRecycling", { title: "Food Recycling" });
});

app.get("/otherServices", (req, res) => {
  res.render("otherServices", { title: "Other Services" });
});

// signup
app.get("/signup", (req, res) => {
  res.render("signUp", { error: null });
});

app.post("/signupSubmit", async (req, res) => {
  const { name, email, password } = req.body;

  if (!name) {
    return res.render("signUp", { error: "Name is required." });
  }
  if (!email) {
    return res.render("signUp", { error: "Email is required." });
  }
  if (!password) {
    return res.render("signUp", { error: "Password is required." });
  }

  const schema = Joi.object({
    name: Joi.string().max(50).required(),
    email: Joi.string().email().required(),
    password: Joi.string().max(20).required(),
  });

  const { error } = schema.validate({ name, email, password });
  if (error) {
    return res.render("signUp", {
      error: "Invalid input. Please check your details.",
    });
  }

  const hashedPassword = await bcrypt.hash(password, saltRounds);

  // TODO: Replace with a PostgreSQL INSERT query
  // e.g. await POSTGRES_CLIENT.query(
  //   "INSERT INTO POSTGRES_USERS_TABLE (name, email, password) VALUES ($1, $2, $3)",
  //   [name, email, hashedPassword]
  // );
  // await "POSTGRES_INSERT_NEW_USER"({ name, email, password: hashedPassword });

  req.session.authenticated = true;
  req.session.name = name;
  req.session.email = email;
  req.session.cookie.maxAge = expireTime;

  req.session.save((err) => {
    if (err) console.error("Session save error:", err);
    res.redirect("/mainPage");
  });
});

// login
app.get("/loginPage", (req, res) => {
  res.render("loginPage", { error: null });
});

app.post("/loginSubmit", async (req, res) => {
  const { email, password } = req.body;

  const schema = Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().max(20).required(),
  });

  const { error } = schema.validate({ email, password });
  if (error) {
    return res.render("loginPage", {
      error: "Please enter a valid email and password.",
    });
  }

  // TODO: Replace with a PostgreSQL SELECT query
  // e.g. const result = await POSTGRES_CLIENT.query(
  //   "SELECT * FROM POSTGRES_USERS_TABLE WHERE email = $1",
  //   [email]
  // );
  // const user = result.rows[0];
  // const user = await "POSTGRES_FIND_USER_BY_EMAIL"(email);

  if (!user) {
    return res.render("loginPage", {
      error: "Invalid email/password combination.",
    });
  }

  const passwordMatch = await bcrypt.compare(password, user.password);

  if (!passwordMatch) {
    return res.render("loginPage", {
      error: "Invalid email/password combination.",
    });
  }

  req.session.authenticated = true;
  req.session.name = user.name;
  req.session.email = user.email;
  req.session.cookie.maxAge = expireTime;

  req.session.save((err) => {
    if (err) console.error("Session save error:", err);
    res.redirect("/mainPage");
  });
});

// logout
app.get("/logout", (req, res) => {
  req.session.destroy();
  res.redirect("/");
});

app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
