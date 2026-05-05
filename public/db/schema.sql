DROP SCHEMA IF EXISTS Foodle_db CASCADE;
CREATE SCHEMA Foodle_db;

-- services — the main directory
-- id, name, type (enum: food_bank, grocery, recycling, etc.), address, location (PostGIS geography point), phone, website, hours (JSONB), requires_id (bool), is_accessible (bool), dietary_tags (array)
CREATE TABLE services (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,
    address TEXT,
    location GEOGRAPHY(POINT, 4326),
    phone VARCHAR(20),
    website TEXT,
    hours JSONB,
    requires_id BOOLEAN DEFAULT FALSE,
    is_accessible BOOLEAN DEFAULT FALSE,
    dietary_tags TEXT[]
);

-- service_images — photos per service
-- id, service_id (FK), url, uploaded_at
CREATE TABLE service_images (
    id SERIAL PRIMARY KEY,
    service_id INTEGER REFERENCES services(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- flyers — per store, per week
-- id, store_id (FK), valid_from, valid_until, source_url
CREATE TABLE flyers (
    id SERIAL PRIMARY KEY,
    store_id INTEGER REFERENCES services(id) ON DELETE CASCADE,
    valid_from DATE NOT NULL,
    valid_until DATE NOT NULL,
    source_url TEXT
);

-- flyer_items — individual deals within a flyer
-- id, flyer_id (FK), name, description, price, original_price, image_url, category
CREATE TABLE flyer_items (
    id SERIAL PRIMARY KEY,
    flyer_id INTEGER REFERENCES flyers(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL,
    original_price NUMERIC(10, 2),
    image_url TEXT,
    category VARCHAR(100)
);

-- stores — grocery stores specifically (a subset of services)
-- id, service_id (FK), links back to the main services table
CREATE TABLE stores (
    id SERIAL PRIMARY KEY,
    service_id INTEGER REFERENCES services(id) ON DELETE CASCADE
);

-- foodbank — food banks specifically (a subset of services)
-- id, service_id (FK), links back to the main services table
CREATE TABLE foodbank (
    id SERIAL PRIMARY KEY,
    service_id INTEGER REFERENCES services(id) ON DELETE CASCADE
);

-- recycling_centers — recycling centers specifically (a subset of services)
-- id, service_id (FK), links back to the main services table
CREATE TABLE recycling_centers (
    id SERIAL PRIMARY KEY,
    service_id INTEGER REFERENCES services(id) ON DELETE CASCADE
);

-- users — for authentication and personalization
-- id, email, password_hash, name, dietary_preferences (array), is_admin (boolean)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    name VARCHAR(255),
    dietary_preferences TEXT[],
    is_admin BOOLEAN DEFAULT FALSE
);

-- user_favorites — linking users to their favorite services
-- id, user_id (FK), service_id (FK)
CREATE TABLE user_favorites (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    service_id INTEGER REFERENCES services(id) ON DELETE CASCADE,
    UNIQUE(user_id, service_id)
);

