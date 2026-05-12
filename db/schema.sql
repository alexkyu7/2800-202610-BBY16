DROP SCHEMA IF EXISTS Foodle_db CASCADE;
CREATE SCHEMA Foodle_db;
SET search_path TO Foodle_db;

CREATE EXTENSION IF NOT EXISTS postgis;

-- SERVICES — the main directory
-- id, name, type (enum: food_bank, grocery, recycling, etc.), 
-- address, location (PostGIS geography point), phone, website, hours (JSONB), 
-- requires_id (bool), is_accessible (bool), dietary_tags (array)
CREATE TABLE services (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    name VARCHAR(255) NOT NULL CHECK (LENGTH(name) > 0),

    -- Existing type field kept for compatibility
    type VARCHAR(50) NOT NULL,

    -- Home page URL for the service, if available
    homepage_url TEXT,

    -- Original address kept
    address TEXT,

    -- Added normalized address structure
    street_address TEXT,
    city VARCHAR(100),
    province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'Canada',

    -- PostGIS geography point
    location GEOGRAPHY(POINT, 4326),

    phone VARCHAR(20),
    website TEXT,

    -- Existing JSONB kept
    hours JSONB,

    requires_id BOOLEAN DEFAULT FALSE,
    is_accessible BOOLEAN DEFAULT FALSE,

    -- Added more detailed accessibility support
    accessibility_features TEXT[],

    -- Existing dietary tags kept
    dietary_tags TEXT[],

    -- Added generalized tags
    tags TEXT[],

    -- Added flexible eligibility info
    eligibility_requirements TEXT,

    -- Verification support
    is_verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMP,

    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Spatial index for fast nearby searches
CREATE INDEX idx_services_location
ON services
USING GIST(location);

-- Useful search indexes
CREATE INDEX idx_services_name ON services(name);
CREATE INDEX idx_services_type ON services(type);

-- OPERATING HOURS (normalized version of hours JSONB)
-- Existing hours JSONB was preserved

CREATE TABLE operating_hours (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    service_id INTEGER REFERENCES services(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    open_time TIME,
    close_time TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- SERVICE CATEGORIES
-- Added scalable category system
-- Existing subtype tables preserved below

CREATE TABLE service_categories (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE service_category_map (
    service_id INTEGER REFERENCES services(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES service_categories(id) ON DELETE CASCADE,
    PRIMARY KEY(service_id, category_id)
);

-- SERVICE IMAGES — photos per service
-- id, service_id (FK), url, uploaded_at
CREATE TABLE service_images (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    service_id INTEGER REFERENCES services(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- FLYERS — per store, per week
-- id, store_id (FK), valid_from, valid_until, source_url
CREATE TABLE flyers (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    store_id INTEGER REFERENCES services(id) ON DELETE CASCADE,
    valid_from DATE NOT NULL,
    valid_until DATE NOT NULL,
    source_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CHECK (valid_until >= valid_from)
);

-- FLYER ITEMS — individual deals within a flyer
-- id, flyer_id (FK), name, description, price, original_price, image_url, category
CREATE TABLE flyer_items (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    flyer_id INTEGER REFERENCES flyers(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL CHECK (LENGTH(name) > 0),
    description TEXT,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    original_price NUMERIC(10, 2)
        CHECK (original_price IS NULL OR original_price >= 0),
    image_url TEXT,
    category VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- STORES — grocery stores specifically (a subset of services)
-- id, service_id (FK), links back to the main services table
CREATE TABLE stores (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    service_id INTEGER REFERENCES services(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- FOOD BANKS — food banks specifically (a subset of services)
-- id, service_id (FK), links back to the main services table
CREATE TABLE foodbank (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    service_id INTEGER REFERENCES services(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- RECYCLING CENTERS — recycling centers specifically (a subset of services)
-- id, service_id (FK), links back to the main services table
CREATE TABLE recycling_centers (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    service_id INTEGER REFERENCES services(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- USERS — for authentication and personalization
-- id, email, password_hash, name, dietary_preferences (array), is_admin (boolean)
CREATE TABLE users (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    name VARCHAR(255),
    dietary_preferences TEXT[],
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- USER FAVOURITES — linking users to their favorite services
-- id, user_id (FK), service_id (FK)
CREATE TABLE user_favorites (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    service_id INTEGER REFERENCES services(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, service_id)
);

