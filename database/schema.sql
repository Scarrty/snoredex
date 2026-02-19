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
