-- This file was converted into SQL by ChatGPT along with my prompts to help it convert all the information properly.
-- It was given a list of real services with name, address, website, operating hours, and phone numbers. The prompt was 'Can you convert this list into 
-- runnable SQL based on this schema'.

SET search_path TO foodle_db;

-- ==========================================
-- Additional Service Categories
-- ==========================================

INSERT INTO service_categories (name)
VALUES
('Food Bank'),
('Community Kitchen'),
('Community Meal'),
('Shelter Support'),
('Youth Support'),
('Emergency Food'),
('Recycling Depot')
ON CONFLICT (name) DO NOTHING;

-- ==========================================
-- SERVICES
-- ==========================================

INSERT INTO services (
    name,
    type,
    address,
    street_address,
    city,
    province,
    postal_code,
    country,
    location,
    phone,
    website,
    hours,
    requires_id,
    is_accessible,
    accessibility_features,
    dietary_tags,
    tags,
    eligibility_requirements,
    is_verified,
    verified_at
)
VALUES
(
    'Sources Community Resource Centre Food Bank',
    'food_bank',
    '882 Maple St, White Rock, BC V4B 4M2',
    '882 Maple St',
    'White Rock',
    'BC',
    'V4B 4M2',
    'Canada',
    ST_GeogFromText('POINT(-122.8019 49.0256)'),
    '6045318168',
    'https://www.sourcesbc.ca',
    '{
        "monday": "9:00-16:00",
        "tuesday": "9:00-16:00",
        "wednesday": "9:00-16:00",
        "thursday": "9:00-16:00",
        "friday": "9:00-15:00",
        "saturday": "closed",
        "sunday": "closed"
    }'::jsonb,
    true,
    true,
    ARRAY['Wheelchair Accessible Entrance', 'Accessible Washroom'],
    ARRAY['Halal Options', 'Vegetarian'],
    ARRAY['Food Hampers', 'Family Support', 'Emergency Assistance'],
    'Government-issued ID and proof of address may be required.',
    true,
    CURRENT_TIMESTAMP
),
(
    'Surrey Food Bank',
    'food_bank',
    '10732 City Pkwy, Surrey, BC V3T 2L6',
    '10732 City Pkwy',
    'Surrey',
    'BC',
    'V3T 2L6',
    'Canada',
    ST_GeogFromText('POINT(-122.8451 49.1978)'),
    '6045815443',
    'https://surreyfoodbank.org',
    '{
        "monday": "9:00-15:00",
        "tuesday": "9:00-15:00",
        "wednesday": "9:00-15:00",
        "thursday": "9:00-15:00",
        "friday": "9:00-15:00",
        "saturday": "closed",
        "sunday": "closed"
    }'::jsonb,
    true,
    true,
    ARRAY['Wheelchair Accessible Entrance', 'Accessible Parking'],
    ARRAY['Vegetarian', 'Gluten-Free'],
    ARRAY['Food Hampers', 'Senior Support', 'Emergency Food'],
    'Registration required for recurring food support.',
    true,
    CURRENT_TIMESTAMP
),
(
    'Cloverdale Community Kitchen',
    'community_kitchen',
    '5336 180 St, Surrey, BC V3S 4K5',
    '5336 180 St',
    'Surrey',
    'BC',
    'V3S 4K5',
    'Canada',
    ST_GeogFromText('POINT(-122.7304 49.0999)'),
    '6043721977',
    'https://www.cloverdalekitchen.ca',
    '{
        "monday": "10:00-18:00",
        "tuesday": "10:00-18:00",
        "wednesday": "10:00-18:00",
        "thursday": "10:00-18:00",
        "friday": "10:00-16:00",
        "saturday": "closed",
        "sunday": "closed"
    }'::jsonb,
    false,
    true,
    ARRAY['Wheelchair Accessible Entrance'],
    ARRAY['Vegetarian', 'Dairy-Free'],
    ARRAY['Cooking Classes', 'Community Meals', 'Youth Programs'],
    'Open to all community members.',
    true,
    CURRENT_TIMESTAMP
),
(
    'Union Gospel Mission Meal Centre',
    'community_meal',
    '658 Clarkson St, New Westminster, BC V3M 1E1',
    '658 Clarkson St',
    'New Westminster',
    'BC',
    'V3M 1E1',
    'Canada',
    ST_GeogFromText('POINT(-122.9127 49.2012)'),
    '6045250071',
    'https://ugm.ca',
    '{
        "monday": "7:00-19:00",
        "tuesday": "7:00-19:00",
        "wednesday": "7:00-19:00",
        "thursday": "7:00-19:00",
        "friday": "7:00-19:00",
        "saturday": "8:00-18:00",
        "sunday": "8:00-18:00"
    }'::jsonb,
    false,
    true,
    ARRAY['Wheelchair Accessible Entrance', 'Accessible Seating'],
    ARRAY['Vegetarian'],
    ARRAY['Hot Meals', 'Emergency Support', 'Outreach'],
    'No eligibility requirements.',
    true,
    CURRENT_TIMESTAMP
),
(
    'Richmond Food Bank Society',
    'food_bank',
    '100-5800 Cedarbridge Way, Richmond, BC V6X 2A7',
    '5800 Cedarbridge Way',
    'Richmond',
    'BC',
    'V6X 2A7',
    'Canada',
    ST_GeogFromText('POINT(-123.1237 49.1705)'),
    '6042715609',
    'https://richmondfoodbank.org',
    '{
        "monday": "8:30-16:00",
        "tuesday": "8:30-16:00",
        "wednesday": "8:30-16:00",
        "thursday": "8:30-16:00",
        "friday": "8:30-13:00",
        "saturday": "closed",
        "sunday": "closed"
    }'::jsonb,
    true,
    true,
    ARRAY['Wheelchair Accessible Entrance', 'Accessible Parking'],
    ARRAY['Halal Options', 'Low Sodium'],
    ARRAY['Food Hampers', 'School Programs', 'Senior Programs'],
    'Proof of Richmond residency required for recurring services.',
    true,
    CURRENT_TIMESTAMP
),
(
    'Aunt Leahs Community Fridge',
    'food_distribution',
    '33771 George Ferguson Way, Abbotsford, BC V2S 2M5',
    '33771 George Ferguson Way',
    'Abbotsford',
    'BC',
    'V2S 2M5',
    'Canada',
    ST_GeogFromText('POINT(-122.2928 49.0504)'),
    '6048524722',
    'https://www.auntleahs.org',
    '{
        "monday": "0:00-23:59",
        "tuesday": "0:00-23:59",
        "wednesday": "0:00-23:59",
        "thursday": "0:00-23:59",
        "friday": "0:00-23:59",
        "saturday": "0:00-23:59",
        "sunday": "0:00-23:59"
    }'::jsonb,
    false,
    true,
    ARRAY['Outdoor Access'],
    ARRAY['Vegetarian'],
    ARRAY['Free Fridge', 'Grab and Go', 'Emergency Food'],
    'Open access community fridge.',
    true,
    CURRENT_TIMESTAMP
),
(
    'Return-It Express South Surrey',
    'recycling_center',
    '2411 King George Blvd, Surrey, BC V4P 1H9',
    '2411 King George Blvd',
    'Surrey',
    'BC',
    'V4P 1H9',
    'Canada',
    ST_GeogFromText('POINT(-122.7816 49.0463)'),
    '6045427866',
    'https://www.return-it.ca',
    '{
        "monday": "9:00-18:00",
        "tuesday": "9:00-18:00",
        "wednesday": "9:00-18:00",
        "thursday": "9:00-18:00",
        "friday": "9:00-18:00",
        "saturday": "9:00-18:00",
        "sunday": "10:00-17:00"
    }'::jsonb,
    false,
    true,
    ARRAY['Wheelchair Accessible Entrance', 'Accessible Parking'],
    ARRAY[]::TEXT[],
    ARRAY['Bottle Depot', 'Recycling', 'Electronics Recycling'],
    'No eligibility requirements.',
    true,
    CURRENT_TIMESTAMP
),
(
    'NightShift Street Ministries Food Support',
    'food_distribution',
    '10635 King George Blvd, Surrey, BC V3T 2X6',
    '10635 King George Blvd',
    'Surrey',
    'BC',
    'V3T 2X6',
    'Canada',
    ST_GeogFromText('POINT(-122.8457 49.1969)'),
    '6049531114',
    'https://nightshiftministries.org',
    '{
        "monday": "18:00-22:00",
        "tuesday": "18:00-22:00",
        "wednesday": "18:00-22:00",
        "thursday": "18:00-22:00",
        "friday": "18:00-22:00",
        "saturday": "18:00-22:00",
        "sunday": "18:00-22:00"
    }'::jsonb,
    false,
    true,
    ARRAY['Wheelchair Accessible Entrance'],
    ARRAY['Vegetarian'],
    ARRAY['Street Outreach', 'Emergency Meals', 'Hygiene Kits'],
    'Open to anyone needing support.',
    true,
    CURRENT_TIMESTAMP
);

-- ==========================================
-- FOOD BANK TABLE
-- ==========================================

INSERT INTO foodbank (service_id)
SELECT id
FROM services
WHERE type = 'food_bank'
AND name IN (
    'Sources Community Resource Centre Food Bank',
    'Surrey Food Bank',
    'Richmond Food Bank Society'
);

-- ==========================================
-- RECYCLING CENTERS TABLE
-- ==========================================

INSERT INTO recycling_centers (service_id)
SELECT id
FROM services
WHERE type = 'recycling_center';

-- ==========================================
-- OPERATING HOURS
-- ==========================================

INSERT INTO operating_hours (service_id, day_of_week, open_time, close_time)
SELECT id, 1, '09:00', '16:00'
FROM services
WHERE name = 'Sources Community Resource Centre Food Bank';

INSERT INTO operating_hours (service_id, day_of_week, open_time, close_time)
SELECT id, 2, '09:00', '16:00'
FROM services
WHERE name = 'Sources Community Resource Centre Food Bank';

INSERT INTO operating_hours (service_id, day_of_week, open_time, close_time)
SELECT id, 3, '09:00', '16:00'
FROM services
WHERE name = 'Sources Community Resource Centre Food Bank';

INSERT INTO operating_hours (service_id, day_of_week, open_time, close_time)
SELECT id, 4, '09:00', '16:00'
FROM services
WHERE name = 'Sources Community Resource Centre Food Bank';

INSERT INTO operating_hours (service_id, day_of_week, open_time, close_time)
SELECT id, 5, '09:00', '15:00'
FROM services
WHERE name = 'Sources Community Resource Centre Food Bank';

-- ==========================================
-- SERVICE CATEGORY MAPS
-- ==========================================

INSERT INTO service_category_map (service_id, category_id)
SELECT s.id, c.id
FROM services s
JOIN service_categories c
ON c.name = 'Food Bank'
WHERE s.type = 'food_bank';

INSERT INTO service_category_map (service_id, category_id)
SELECT s.id, c.id
FROM services s
JOIN service_categories c
ON c.name = 'Community Kitchen'
WHERE s.type = 'community_kitchen';

INSERT INTO service_category_map (service_id, category_id)
SELECT s.id, c.id
FROM services s
JOIN service_categories c
ON c.name = 'Community Meal'
WHERE s.type = 'community_meal';

INSERT INTO service_category_map (service_id, category_id)
SELECT s.id, c.id
FROM services s
JOIN service_categories c
ON c.name = 'Recycling Depot'
WHERE s.type = 'recycling_center';

-- ==========================================
-- SAMPLE SERVICE IMAGES
-- ==========================================

INSERT INTO service_images (service_id, url)
SELECT id, 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c'
FROM services
WHERE name = 'Surrey Food Bank';

INSERT INTO service_images (service_id, url)
SELECT id, 'https://images.unsplash.com/photo-1593113598332-cd59a93c6138'
FROM services
WHERE name = 'Union Gospel Mission Meal Centre';

INSERT INTO service_images (service_id, url)
SELECT id, 'https://images.unsplash.com/photo-1520607162513-77705c0f0d4a'
FROM services
WHERE name = 'Return-It Express South Surrey';