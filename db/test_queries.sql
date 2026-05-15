-- TEST QUERIES FOR foodle_db

-- SERVICES
SELECT * FROM foodle_db.services;

-- USERS
SELECT * FROM foodle_db.users;

-- COUNT SERVICES
SELECT COUNT(*) FROM foodle_db.services;

-- COUNT USERS
SELECT COUNT(*) FROM foodle_db.users;

-- FIND ONLY FOOD BANKS
SELECT name, city
FROM foodle_db.services
WHERE type = 'food_bank';

-- FIND ONLY COMMUNITY KITCHENS
SELECT name, address
FROM foodle_db.services
WHERE type = 'community_kitchen';

-- SORT ALPHABETICALLY
SELECT name
FROM foodle_db.services
ORDER BY name ASC;

-- SEARCH BY CITY
SELECT *
FROM foodle_db.services
WHERE city = 'Vancouver';

-- SEARCH BY PARTIAL NAME
SELECT * 
FROM foodle_db.services
WHERE name ILIKE '%food%';

-- VERIFY PASSWORD HASHING
SELECT email, password_hash
FROM foodle_db.users;
-- Should see hashes beginning with $2b$

-- TEST SINGLE SERVICE LOOKUP
-- Simulates GET /services/:id
SELECT * 
FROM foodle_db.services
WHERE id = 1;

-- VERIFY NO NULL NAMES
SELECT *
FROM foodle_db.services
WHERE name IS NULL;

-- VERIFY DISTINCT SERVICE TYPES
SELECT DISTINCT type
FROM foodle_db.services;