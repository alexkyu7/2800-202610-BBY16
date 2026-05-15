-- Services

INSERT INTO foodle_db.services (
    name,
    type,
    street_address,
    city,
    province,
    postal_code,
    phone,
    website
)

VALUES 
(
    'Greater Vancouver Food Bank',
    'food_bank',
    '3454 Lougheed Hwy',
    'Vancouver',
    'BC',
    'V5M 2A4',
    '6048763601',
    'https://foodbank.bc.ca'
),

(
    'Muslim Food Bank Vancouver',
    'food_bank',
    '140 E Hastings St',
    'Vancouver',
    'BC',
    'V6A 0E6',
    '6043439895',
    'https://muslimfoodbank.com/vancouver'
),

(
    'JFS The Kitchen',
    'community_kitchen',
    '54 E 3rd Ave',
    'Vancouver',
    'BC',
    'V5T 1C3',
    '6045585727',
    'https://www.jfsvancouver.ca'
),

(
    'Gordon Neighbourhood House Community Kitchen',
    'community_kitchen',
    '1019 Broughton St',
    'Vancouver',
    'BC',
    'V6G 2A7',
    '6046832554',
    'https://gordonhouse.org/our-kitchen'
),

(
    'DTES Emergency Supply Hub',
    'food_distribution',
    '140 E Hastings St',
    'Vancouver',
    'BC',
    'V6A 1N4',
    '6046794019',
    'https://www.dteshub.ca'
),

(
    'Guru Nanaks Free Kitchen Society',
    'community_meal',
    '245 E Hastings St',
    'Vancouver',
    'BC',
    'V6A 1P2',
    '6046177382',
    'http://www.gnfk.org'
),

(
    'CityReach Care Society',
    'food_bank',
    '2650 Slocan St',
    'Vancouver',
    'BC',
    'V5M 4E9',
    '6042542489',
    'https://www.cityreach.org'
);

-- Sample Users
INSERT INTO foodle_db.users (
    name, 
    email, 
    password_hash
)

VALUES 

(
    'Test User',
    'testuser@email.com',
    '$2b$12$abcdefghijklmnopqrstuv'
),

(
    'Admin User',
    'admin@foodle.ca',
    '$2b$12$abcdefghijklmnopqrstuv'
);

