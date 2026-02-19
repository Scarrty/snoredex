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

CREATE TABLE inventory_items (
    card_print_id INTEGER NOT NULL REFERENCES card_prints(id) ON DELETE CASCADE,
    owner_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL REFERENCES locations(id),
    quantity_on_hand INTEGER NOT NULL DEFAULT 0 CHECK (quantity_on_hand >= 0),
    quantity_reserved INTEGER NOT NULL DEFAULT 0 CHECK (quantity_reserved >= 0),
    quantity_damaged INTEGER NOT NULL DEFAULT 0 CHECK (quantity_damaged >= 0),
    PRIMARY KEY (card_print_id, owner_id, location_id)
);

CREATE INDEX idx_inventory_items_card_print_id
    ON inventory_items(card_print_id);

CREATE INDEX idx_inventory_items_owner_location
    ON inventory_items(owner_id, location_id);

CREATE INDEX idx_inventory_items_quantity_on_hand
    ON inventory_items(quantity_on_hand);

CREATE INDEX idx_card_prints_set_id
    ON card_prints(set_id);

CREATE INDEX idx_card_prints_pokemon_id
    ON card_prints(pokemon_id);

CREATE INDEX idx_card_prints_type_id
    ON card_prints(type_id);

CREATE INDEX idx_card_prints_card_number
    ON card_prints(card_number);

CREATE INDEX idx_sets_era_id
    ON sets(era_id);

CREATE INDEX idx_sets_set_code
    ON sets(set_code);

CREATE INDEX idx_card_print_languages_language_id
    ON card_print_languages(language_id);

CREATE INDEX idx_card_print_languages_card_print_id
    ON card_print_languages(card_print_id);

CREATE INDEX idx_cardmarket_listings_card_print_is_available
    ON cardmarket_listings(card_print_id, is_available);

CREATE INDEX idx_inventory_items_available_card_print
    ON inventory_items(card_print_id)
    WHERE quantity_on_hand > quantity_reserved + quantity_damaged;

CREATE INDEX idx_card_prints_set_type_card_number
    ON card_prints(set_id, type_id, card_number);

CREATE INDEX idx_card_print_languages_language_card_print
    ON card_print_languages(language_id, card_print_id);

CREATE INDEX idx_cardmarket_listings_available_card_print
    ON cardmarket_listings(is_available, card_print_id);

