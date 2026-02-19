Overview

This schema converts the flat Excel structure into a normalized relational database model.

Goals:

Remove repetition (especially languages and sets)

Support future Pokémon additions

Support multiple print variations

Maintain marketplace references

Enable multilingual release tracking

Track procurement and sales economics

Entity Relationship Overview
Pokemon ──< CardPrint >── Set
                   │
                   ├──< CardMarketListing
                   │
                   ├──< CardPrintLanguage >── Language
                   │
                   ├──< InventoryItem >── Location
                   │
                   ├──< AcquisitionLine >── Acquisition
                   │
                   └──< SalesLine >── Sale

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

11. acquisitions

Tracks inbound procurement transactions.

CREATE TABLE acquisitions (
    id SERIAL PRIMARY KEY,
    acquired_at DATE NOT NULL,
    supplier_reference VARCHAR(255),
    channel VARCHAR(100),
    currency VARCHAR(3) NOT NULL,
    notes TEXT
);

Examples

Supplier reference: cardmarket_seller_123, local_store_foo

Channel: Cardmarket, eBay, local

12. acquisition_lines

Line-level acquisition economics tied to inventory records.

CREATE TABLE acquisition_lines (
    id SERIAL PRIMARY KEY,
    acquisition_id INTEGER NOT NULL REFERENCES acquisitions(id) ON DELETE CASCADE,
    card_print_id INTEGER NOT NULL,
    owner_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    language_id INTEGER REFERENCES languages(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_cost NUMERIC(12, 2) NOT NULL CHECK (unit_cost >= 0),
    fees NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (fees >= 0),
    shipping NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (shipping >= 0),
    FOREIGN KEY (card_print_id, owner_id, location_id)
        REFERENCES inventory_items(card_print_id, owner_id, location_id)
);

13. sales

Tracks outbound card sales transactions.

CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    sold_at DATE NOT NULL,
    buyer_reference VARCHAR(255),
    channel VARCHAR(100),
    currency VARCHAR(3) NOT NULL,
    notes TEXT
);

14. sales_lines

Line-level sales economics tied to inventory records.

CREATE TABLE sales_lines (
    id SERIAL PRIMARY KEY,
    sale_id INTEGER NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
    card_print_id INTEGER NOT NULL,
    owner_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    language_id INTEGER REFERENCES languages(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_sale_price NUMERIC(12, 2) NOT NULL CHECK (unit_sale_price >= 0),
    fees NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (fees >= 0),
    shipping NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (shipping >= 0),
    FOREIGN KEY (card_print_id, owner_id, location_id)
        REFERENCES inventory_items(card_print_id, owner_id, location_id)
);

15. reporting_avg_acquisition_cost (view)

Computes average unit cost (inclusive of line fees/shipping allocations) per inventory key and language.

16. reporting_profitability_by_card_set_language (view)

Aggregates sold quantity, gross revenue, COGS, gross margin, and realized profit by:

Card print

Set

Language

Realized profit logic:

Revenue net of sale-side fees and shipping, minus average acquisition cost for sold quantities.
