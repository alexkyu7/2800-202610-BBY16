const express = require('express');
const router = express.Router();
const { supabaseAdmin } = require('../db/connection'); // Service role client — bypasses RLS, server-side only

// POST /aiSearch
// Body: { location: string, query: string (optional) }
router.post('/', async (req, res) => {
    const { location, query } = req.body;

    if (!location || location.trim() === '') {
        return res.status(400).json({ error: 'A location is required.' });
    }

    try {
        // Fetch services from the database that match the user's location.
        // Supabase JS client uses .from().select() instead of pool.query().
        // Adjust the column names below if your schema uses different names.
        const { data: servicesFromDB, error: dbError } = await supabaseAdmin
            // .schema('foodle_db')
            .from('services')
            .select('name, address, city, description, discount_info, category, phone, website')
            .or(`city.ilike.%${location.trim()}%,address.ilike.%${location.trim()}%`)
            .limit(60);

        if (dbError) {
            console.error('Database error:', dbError);
            return res.status(500).json({ error: 'Could not fetch services from the database.' });
        }

        if (!servicesFromDB || servicesFromDB.length === 0) {
            return res.json({
                results: [],
                summary: `No services were found in your database for "${location}". Try a different city or postal code.`
            });
        }

        // Send the services to Claude and ask it to rank them by discounts/deals
        const claudeResponse = await fetch('https://api.anthropic.com/v1/messages', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'x-api-key': process.env.ANTHROPIC_API_KEY,
                'anthropic-version': '2023-06-01'
            },
            body: JSON.stringify({
                model: 'claude-sonnet-4-20250514',
                max_tokens: 2048,
                system: `You are a helpful assistant for Foodle, a food assistance app.
You will be given a list of food services/stores near a user's location.
Your job is to rank them from most discounts/deals to least, based on the information provided.
You must respond ONLY with a valid JSON object — no explanation, no markdown, no backticks.
The JSON must have this exact shape:
{
  "summary": "One sentence describing the results",
  "results": [
    {
      "name": "Service name",
      "address": "Full address",
      "category": "Category",
      "phone": "Phone number or null",
      "website": "Website URL or null",
      "discountHighlight": "Short sentence about why this ranks here — what discount or deal it offers, or 'No specific discounts listed' if none"
    }
  ]
}`,
                messages: [
                    {
                        role: 'user',
                        content: `Location the user searched: ${location}
${query ? `Extra context from the user: ${query}` : ''}

Here are the services found in the database. Please rank them from most discounts/deals to least:

${JSON.stringify(servicesFromDB, null, 2)}`
                    }
                ]
            })
        });

        const claudeData = await claudeResponse.json();

        if (!claudeResponse.ok) {
            console.error('Claude API error:', claudeData);
            return res.status(502).json({ error: 'AI service unavailable. Please try again.' });
        }

        const rawText = claudeData.content[0].text;
        const parsed = JSON.parse(rawText);

        return res.json(parsed);

    } catch (err) {
        console.error('AI search error:', err);
        return res.status(500).json({ error: 'Something went wrong. Please try again.' });
    }
});

module.exports = router;