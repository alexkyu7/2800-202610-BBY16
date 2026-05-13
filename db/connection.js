// import { createClient } from "@supabase/supabase-js";
// import dotenv from "dotenv";
// dotenv.config();

// const supabaseUrl = process.env.DATABASE_URL;
// const supabaseKey = process.env.SUPABASE_API_KEY;

// export const supabase = createClient(supabaseUrl, supabaseKey);

// The above code is the original ES module version. Below is the CommonJS version for compatibility with Node.js without additional configuration.
/**
 * Edited by Claude
 */
const { createClient } = require("@supabase/supabase-js");
require("dotenv").config();

const supabaseUrl = process.env.DATABASE_URL;
const supabaseKey = process.env.SUPABASE_API_KEY;

const supabase = createClient(supabaseUrl, supabaseKey);

module.exports = { supabase };
