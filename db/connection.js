const { createClient } = require("@supabase/supabase-js");
require("dotenv").config();

const supabaseUrl = process.env.DATABASE_URL;
const supabaseAnonKey = process.env.SUPABASE_API_KEY;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

// Public client — uses the anon/publishable key, respects Row Level Security.
// Targets the 'public' schema (Supabase default — no extra exposure needed).
const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Admin client — uses the service role key, BYPASSES Row Level Security.
// Never expose this key to the browser. Server-side use only.
const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

module.exports = { supabase, supabaseAdmin };