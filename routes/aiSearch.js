const express = require('express');
const router  = express.Router();
const pool    = require('../db/connection'); // direct pg Pool — pool.query() works natively

// POST /aiSearch
// Body: { location: string, query: string (optional) }
router.post('/', async (req, res) => {
    const { location, query } = req.body;

    if (!location || location.trim() === '') {
        return res.status(400).json({ error: 'A location is required.' });
    }

    // Supported dietary tags from free-text query
    const supportedTags = ['halal', 'vegan', 'gluten-free'];
    const queryText = (query || '').toLowerCase();
    const matchedTags = supportedTags.filter((tag) => queryText.includes(tag));
    const tagPatterns = matchedTags.length > 0
        ? matchedTags.map((t) => `%${t}%`)
        : null;

    try {
        // Fetch services from the database that match the user's location + tags.
        const dbResult = await pool.query(
            `SELECT
                 name,
                 address,
                 city,
                 type,
                 dietary_tags,
                 tags,
                 description,
                 discount_info,
                 phone,
                 website
             FROM foodle_db.services
             WHERE (city ILIKE $1 OR address ILIKE $1)
               AND (
                 $2::text[] IS NULL
                 OR EXISTS (
                     SELECT 1
                     FROM unnest(dietary_tags || tags) AS t
                     WHERE t ILIKE ANY ($2::text[])
                    )
                 )
                 LIMIT 60`,
            [`%${location.trim()}%`, tagPatterns]
        );

        const servicesFromDB = dbResult.rows;

        if (servicesFromDB.length === 0) {
            return res.json({
                results: [],
                summary: `No services were found in your database for "${location}". Try a different city or postal code.`
            });
        }

        const systemPrompt = `You are a helpful assistant for Foodle, a food assistance app.
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
      "type": "Service type",
      "phone": "Phone number or null",
      "website": "Website URL or null",
      "discountHighlight": "Short sentence about why this ranks here — what discount or deal it offers, or 'No specific discounts listed' if none"
    }
  ]
}`;

        const userPrompt = `Location the user searched: ${location}
${query ? `Extra context from the user: ${query}` : ''}

Here are the services found in the database. Please rank them from most discounts/deals to least:

${JSON.stringify(servicesFromDB, null, 2)}`;

        let parsed;

        try {
            const openrouterResponse = await fetch('https://openrouter.ai/api/v1/chat/completions', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${process.env.OPENROUTER_API_KEY}`,
                    'HTTP-Referer': 'http://localhost:3000',
                    'X-Title': 'Foodle AI Search'
                },
                body: JSON.stringify({
                    model: 'deepseek/deepseek-v4-flash:free',
                    max_tokens: 2048,
                    messages: [
                        { role: 'system', content: systemPrompt },
                        { role: 'user', content: userPrompt }
                    ]
                })
            });

            const openrouterData = await openrouterResponse.json();

            if (!openrouterResponse.ok) {
                throw new Error(`OpenRouter error: ${JSON.stringify(openrouterData)}`);
            }

            const rawText = openrouterData.choices?.[0]?.message?.content || '';
            parsed = JSON.parse(rawText);
        } catch (aiErr) {
            console.error('OpenRouter AI error, falling back to mock:', aiErr);

            // Mock fallback: simple deterministic ranking
            const mockResults = servicesFromDB.map((s) => ({
                name: s.name,
                address: s.address,
                type: s.type,
                phone: s.phone || null,
                website: s.website || null,
                discountHighlight: s.discount_info
                    ? `Discount info: ${s.discount_info}`
                    : 'No specific discounts listed'
            }));

            parsed = {
                summary: `Showing ${mockResults.length} services from your database for "${location}".`,
                results: mockResults
            };
        }

        return res.json(parsed);

    } catch (err) {
        console.error('AI search error:', err);
        return res.status(500).json({ error: 'Something went wrong. Please try again.' });
    }
});

module.exports = router;