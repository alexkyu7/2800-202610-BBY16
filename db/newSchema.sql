-- Drop old custom schema if it exists from a previous run
DROP SCHEMA IF EXISTS Foodle_db CASCADE;

CREATE EXTENSION IF NOT EXISTS postgis;

-- SERVICES — the main directory
CREATE TABLE IF NOT EXISTS public.services (
                                               id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

                                               name VARCHAR(255) NOT NULL CHECK (LENGTH(name) > 0),

    type VARCHAR(50) NOT NULL,

    address TEXT,
    street_address TEXT,
    city VARCHAR(100),
    province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'Canada',

    location GEOGRAPHY(POINT, 4326),

    phone VARCHAR(20),
    website TEXT,
    hours JSONB,

    requires_id BOOLEAN DEFAULT FALSE,
    is_accessible BOOLEAN DEFAULT FALSE,
    accessibility_features TEXT[],
    dietary_tags TEXT[],
    tags TEXT[],
    eligibility_requirements TEXT,

    -- Added for AI search discount ranking
    discount_info TEXT,
    category VARCHAR(100),

    is_verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMP,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

CREATE INDEX IF NOT EXISTS idx_services_location ON public.services USING GIST(location);
CREATE INDEX IF NOT EXISTS idx_services_name ON public.services(name);
CREATE INDEX IF NOT EXISTS idx_services_type ON public.services(type);

-- OPERATING HOURS
CREATE TABLE IF NOT EXISTS public.operating_hours (
                                                      id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                                                      service_id INTEGER REFERENCES public.services(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    open_time TIME,
    close_time TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

-- SERVICE CATEGORIES
CREATE TABLE IF NOT EXISTS public.service_categories (
                                                         id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                                                         name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

CREATE TABLE IF NOT EXISTS public.service_category_map (
                                                           service_id INTEGER REFERENCES public.services(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES public.service_categories(id) ON DELETE CASCADE,
    PRIMARY KEY(service_id, category_id)
    );

-- SERVICE IMAGES
CREATE TABLE IF NOT EXISTS public.service_images (
                                                     id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                                                     service_id INTEGER REFERENCES public.services(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

-- FLYERS
CREATE TABLE IF NOT EXISTS public.flyers (
                                             id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                                             store_id INTEGER REFERENCES public.services(id) ON DELETE CASCADE,
    valid_from DATE NOT NULL,
    valid_until DATE NOT NULL,
    source_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (valid_until >= valid_from)
    );

-- FLYER ITEMS
CREATE TABLE IF NOT EXISTS public.flyer_items (
                                                  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                                                  flyer_id INTEGER REFERENCES public.flyers(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL CHECK (LENGTH(name) > 0),
    description TEXT,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    original_price NUMERIC(10, 2) CHECK (original_price IS NULL OR original_price >= 0),
    image_url TEXT,
    category VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

-- STORES
CREATE TABLE IF NOT EXISTS public.stores (
                                             id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                                             service_id INTEGER REFERENCES public.services(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

-- FOOD BANKS
CREATE TABLE IF NOT EXISTS public.foodbank (
                                               id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                                               service_id INTEGER REFERENCES public.services(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

-- RECYCLING CENTERS
CREATE TABLE IF NOT EXISTS public.recycling_centers (
                                                        id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                                                        service_id INTEGER REFERENCES public.services(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

-- USERS
CREATE TABLE IF NOT EXISTS public.users (
                                            id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                                            email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    name VARCHAR(255),
    dietary_preferences TEXT[],
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

-- USER FAVOURITES
CREATE TABLE IF NOT EXISTS public.user_favorites (
                                                     id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                                                     user_id INTEGER REFERENCES public.users(id) ON DELETE CASCADE,
    service_id INTEGER REFERENCES public.services(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, service_id)
    );

-- SESSION STORAGE (used by connect-pg-simple)
CREATE TABLE IF NOT EXISTS public.user_sessions (
                                                    sid VARCHAR NOT NULL PRIMARY KEY,
                                                    sess JSON NOT NULL,
                                                    expire TIMESTAMP(6) NOT NULL
    );
CREATE INDEX IF NOT EXISTS idx_session_expire ON public.user_sessions(expire);

-- ============================================================
-- ROW LEVEL SECURITY
-- Enable RLS on sensitive tables so the anon key cannot read
-- or write data it shouldn't. The service role key bypasses
-- RLS entirely (used server-side only in aiSearch.js).
-- ============================================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_sessions ENABLE ROW LEVEL SECURITY;

-- Block all direct client access — all user queries go through the
-- Express server using the service role key, which bypasses RLS.
-- The anon key should never touch these tables directly.
CREATE POLICY users_server_only ON public.users USING (false);

CREATE POLICY favorites_server_only ON public.user_favorites USING (false);

-- Sessions are fully server-managed; block all direct client access
CREATE POLICY sessions_deny ON public.user_sessions USING (false);

-- Services are public-read, no writes from the client
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
CREATE POLICY services_read ON public.services FOR SELECT USING (true);