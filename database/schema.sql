-- ============================================
-- SNOREDEX DATABASE SCHEMA
-- ============================================

CREATE TABLE pokemon (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    national_dex_no INTEGER
);

CREATE TABLE eras (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE sets (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    set_code VARCHAR(20),
    era_id INTEGER REFERENCES eras(id)
);

CREATE TABLE card_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE card_prints (
    id SERIAL PRIMARY KEY,
    pokemon_id INTEGER NOT NULL REFERENCES pokemon(id),
    set_id INTEGER NOT NULL REFERENCES sets(id),
    card_number VARCHAR(50) NOT NULL,
    type_id INTEGER REFERENCES card_types(id),
    sort_number INTEGER
);

CREATE TABLE languages (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE card_print_languages (
    card_print_id INTEGER REFERENCES card_prints(id) ON DELETE CASCADE,
    language_id INTEGER REFERENCES languages(id) ON DELETE CASCADE,
    PRIMARY KEY (card_print_id, language_id)
);

CREATE TABLE cardmarket_listings (
    id SERIAL PRIMARY KEY,
    card_print_id INTEGER REFERENCES card_prints(id) ON DELETE CASCADE,
    url TEXT,
    is_available BOOLEAN
);

CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location_type VARCHAR(100) NOT NULL
);

CREATE TABLE card_conditions (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    sort_order INTEGER NOT NULL UNIQUE
);

CREATE TABLE inventory_items (
    id SERIAL PRIMARY KEY,
    card_print_id INTEGER NOT NULL REFERENCES card_prints(id) ON DELETE CASCADE,
    owner_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL REFERENCES locations(id),
    condition_id INTEGER NOT NULL REFERENCES card_conditions(id),
    grade_provider VARCHAR(100),
    grade_value NUMERIC(3,1),
    quantity_on_hand INTEGER NOT NULL DEFAULT 0 CHECK (quantity_on_hand >= 0),
    quantity_reserved INTEGER NOT NULL DEFAULT 0 CHECK (quantity_reserved >= 0),
    quantity_damaged INTEGER NOT NULL DEFAULT 0 CHECK (quantity_damaged >= 0),
    CONSTRAINT chk_inventory_items_grade_pair
        CHECK ((grade_provider IS NULL) = (grade_value IS NULL)),
    CONSTRAINT chk_inventory_items_grade_range
        CHECK (
            grade_value IS NULL
            OR (
                grade_value >= 1.0
                AND grade_value <= 10.0
                AND grade_value * 2 = floor(grade_value * 2)
            )
        )
);

CREATE UNIQUE INDEX uq_inventory_items_lot_condition_grade
    ON inventory_items(
        card_print_id,
        owner_id,
        location_id,
        condition_id,
        COALESCE(grade_provider, ''),
        COALESCE(grade_value, -1.0)
    );

CREATE INDEX idx_inventory_items_card_print_id
    ON inventory_items(card_print_id);

CREATE INDEX idx_inventory_items_owner_location
    ON inventory_items(owner_id, location_id);

CREATE INDEX idx_inventory_items_condition_id
    ON inventory_items(condition_id);

CREATE INDEX idx_inventory_items_quantity_on_hand
    ON inventory_items(quantity_on_hand);
