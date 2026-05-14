const { supabase } = require("./db/connection");

async function getFilteredServices({ type, dietary, openNow } = {}) {
  let query = supabase.from("services").select("*");

  if (type) {
    query = query.eq("type", type);
  }
  if (dietary) {
    query = query.contains("dietary_tags", [dietary]);
  }
  if (openNow) {
    // example: filter by a boolean column
    query = query.eq("is_open", true);
  }

  const { data, error } = await query;
  if (error) throw error;
  return data;
}

module.exports = { getFilteredServices };
