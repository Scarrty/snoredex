Overview

This schema converts the flat Excel structure into a normalized relational database model.

Goals:

Remove repetition (especially languages and sets)

Support future Pokémon additions

Support multiple print variations

Maintain marketplace references

Enable multilingual release tracking

Entity Relationship Overview
Pokemon ──< CardPrint >── Set
                   │
                   ├──< CardMarketListing
                   │
                   └──< CardPrintLanguage >── Language

Tables
1. pokemon

Stores Pokémon species.

CREATE TABLE pokemon (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    national_dex_no INTEGER NULL
);

Notes

Currently mostly "Snorlax"

Allows expansion to other Pokémon later

national_dex_no optional

2. eras

Represents historical TCG eras.

CREATE TABLE eras (
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(100) NOT NULL
);


Examples:

Original

Neo

EX

Diamond & Pearl

etc.

3. sets

Stores Pokémon TCG sets.

CREATE TABLE sets (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    set_code    VARCHAR(20),
    era_id      INTEGER REFERENCES eras(id)
);

Notes

set_code examples: JU, BS, etc.

Linked to eras

4. card_types

Represents rarity / print classification.

CREATE TABLE card_types (
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(100) NOT NULL
);


Examples:

Holo

Non-Holo

Promo

Reverse Holo

5. card_prints

Core table: one row per unique printed card.

CREATE TABLE card_prints (
    id              SERIAL PRIMARY KEY,
    pokemon_id      INTEGER NOT NULL REFERENCES pokemon(id),
    set_id          INTEGER NOT NULL REFERENCES sets(id),
    card_number     VARCHAR(50) NOT NULL,
    type_id         INTEGER REFERENCES card_types(id),
    sort_number     INTEGER
);

Represents:

One specific card print

One set

One card number

One rarity type

This replaces:

Pokemon

Nr.

Set

Type

Sort Nr.

6. languages

Stores supported card languages.

CREATE TABLE languages (
    id      SERIAL PRIMARY KEY,
    code    VARCHAR(20) UNIQUE NOT NULL,
    name    VARCHAR(100) NOT NULL
);

Example entries
code	name
JP	Japanese
EN	English
DE	German
FR	French
IT	Italian
ES	Spanish
LATM	Latin American Spanish
NL	Dutch
RU	Russian
PL	Polish
KOR	Korean
THAI	Thai
IND	Indonesian
S-CHN	Simplified Chinese
T-CHN	Traditional Chinese
PT	Portuguese
7. card_print_languages

Join table to track language availability.

CREATE TABLE card_print_languages (
    card_print_id  INTEGER REFERENCES card_prints(id) ON DELETE CASCADE,
    language_id    INTEGER REFERENCES languages(id) ON DELETE CASCADE,
    PRIMARY KEY (card_print_id, language_id)
);

Logic

If a record exists → card was printed in that language.
If no record → not released in that language.

This replaces the 16 language columns.

8. cardmarket_listings

Stores marketplace references.

CREATE TABLE cardmarket_listings (
    id              SERIAL PRIMARY KEY,
    card_print_id   INTEGER REFERENCES card_prints(id) ON DELETE CASCADE,
    url             TEXT,
    is_available    BOOLEAN
);


Replaces:

auf CM auffindbar?

Unnamed: 1 (URL column)
9. locations

Stores inventory storage channels/containers.

CREATE TABLE locations (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(255) NOT NULL,
    location_type   VARCHAR(100) NOT NULL
);

Examples:

Binder

Deck box

Warehouse shelf

Sales channel

10. inventory_items

Tracks per-print inventory by owner and location.

CREATE TABLE inventory_items (
    card_print_id       INTEGER NOT NULL REFERENCES card_prints(id) ON DELETE CASCADE,
    owner_id            INTEGER NOT NULL,
    location_id         INTEGER NOT NULL REFERENCES locations(id),
    quantity_on_hand    INTEGER NOT NULL DEFAULT 0 CHECK (quantity_on_hand >= 0),
    quantity_reserved   INTEGER NOT NULL DEFAULT 0 CHECK (quantity_reserved >= 0),
    quantity_damaged    INTEGER NOT NULL DEFAULT 0 CHECK (quantity_damaged >= 0),
    PRIMARY KEY (card_print_id, owner_id, location_id)
);

Indexes

CREATE INDEX idx_inventory_items_card_print_id
    ON inventory_items(card_print_id);

CREATE INDEX idx_inventory_items_owner_location
    ON inventory_items(owner_id, location_id);

CREATE INDEX idx_inventory_items_quantity_on_hand
    ON inventory_items(quantity_on_hand);

11. Join/filter performance indexes

Added indexes for high-frequency joins and filters:

```sql
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
```

Composite/targeted indexes tuned after `EXPLAIN` for representative set + language + availability + condition queries:

```sql
CREATE INDEX idx_card_prints_set_type_card_number
    ON card_prints(set_id, type_id, card_number);

CREATE INDEX idx_card_print_languages_language_card_print
    ON card_print_languages(language_id, card_print_id);

CREATE INDEX idx_cardmarket_listings_available_card_print
    ON cardmarket_listings(is_available, card_print_id);

CREATE INDEX idx_inventory_items_available_card_print
    ON inventory_items(card_print_id)
    WHERE quantity_on_hand > quantity_reserved + quantity_damaged;
```

Representative query shape:

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT cp.id, cp.card_number, s.set_code, cml.url
FROM card_prints cp
JOIN sets s ON s.id = cp.set_id
JOIN card_print_languages cpl ON cpl.card_print_id = cp.id
JOIN cardmarket_listings cml ON cml.card_print_id = cp.id
JOIN inventory_items ii ON ii.card_print_id = cp.id
WHERE s.set_code = 'S77'
  AND cpl.language_id = 5
  AND cml.is_available = TRUE
  AND ii.quantity_on_hand > ii.quantity_reserved + ii.quantity_damaged
  AND cp.type_id = 5
ORDER BY cp.card_number
LIMIT 100;
```
