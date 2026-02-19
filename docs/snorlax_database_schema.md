Overview

This schema converts the flat Excel structure into a normalized relational database model.

Goals:

- Remove repetition (especially languages and sets)
- Support future Pokémon additions
- Support multiple print variations
- Maintain marketplace references
- Enable multilingual release tracking
- Support multiple external marketplaces with one listing model

Track procurement and sales economics

Entity Relationship Overview

Pokemon ──< CardPrint >── Set
                   │
                   ├──< InventoryItem >──< ExternalListing >── Marketplace
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

```sql
CREATE TABLE pokemon (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    national_dex_no INTEGER NULL
);
```

2. eras

Represents historical TCG eras.

```sql
CREATE TABLE eras (
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(100) NOT NULL
);
```

3. sets

Stores Pokémon TCG sets.

```sql
CREATE TABLE sets (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    set_code    VARCHAR(20),
    era_id      INTEGER REFERENCES eras(id)
);
```

4. card_types

Represents rarity / print classification.

```sql
CREATE TABLE card_types (
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(100) NOT NULL
);
```

5. card_prints

Core table: one row per unique printed card.

```sql
CREATE TABLE card_prints (
    id              SERIAL PRIMARY KEY,
    pokemon_id      INTEGER NOT NULL REFERENCES pokemon(id),
    set_id          INTEGER NOT NULL REFERENCES sets(id),
    card_number     VARCHAR(50) NOT NULL,
    type_id         INTEGER REFERENCES card_types(id),
    sort_number     INTEGER
);
```

6. languages

Stores supported card languages.

```sql
CREATE TABLE languages (
    id      SERIAL PRIMARY KEY,
    code    VARCHAR(20) UNIQUE NOT NULL,
    name    VARCHAR(100) NOT NULL
);
```

7. card_print_languages

Join table to track language availability.

```sql
CREATE TABLE card_print_languages (
    card_print_id  INTEGER REFERENCES card_prints(id) ON DELETE CASCADE,
    language_id    INTEGER REFERENCES languages(id) ON DELETE CASCADE,
    PRIMARY KEY (card_print_id, language_id)
);
```

8. locations

Stores inventory storage channels/containers.

```sql
CREATE TABLE locations (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(255) NOT NULL,
    location_type   VARCHAR(100) NOT NULL
);
```

Examples:

Binder

Deck box

Warehouse shelf

Sales channel

10. card_conditions
9. inventory_items

Reference table for card condition standards.

CREATE TABLE card_conditions (
    id          SERIAL PRIMARY KEY,
    code        VARCHAR(20) UNIQUE NOT NULL,
    name        VARCHAR(100) NOT NULL,
    sort_order  INTEGER NOT NULL UNIQUE
);

Examples:

NM (Near Mint)

LP (Lightly Played)

MP (Moderately Played)

HP (Heavily Played)

DMG (Damaged)

11. inventory_items

Tracks lot-level inventory by print, owner, location, and condition.
Each condition (and grade tuple, if present) is a distinct inventory row.

```sql
CREATE TABLE inventory_items (
    id                  SERIAL PRIMARY KEY,
    card_print_id       INTEGER NOT NULL REFERENCES card_prints(id) ON DELETE CASCADE,
    owner_id            INTEGER NOT NULL,
    location_id         INTEGER NOT NULL REFERENCES locations(id),
    condition_id        INTEGER NOT NULL REFERENCES card_conditions(id),
    grade_provider      VARCHAR(100),
    grade_value         NUMERIC(3,1),
    quantity_on_hand    INTEGER NOT NULL DEFAULT 0 CHECK (quantity_on_hand >= 0),
    quantity_reserved   INTEGER NOT NULL DEFAULT 0 CHECK (quantity_reserved >= 0),
    quantity_damaged    INTEGER NOT NULL DEFAULT 0 CHECK (quantity_damaged >= 0),
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
```

CREATE TABLE inventory_movements (
    id                  SERIAL PRIMARY KEY,
    inventory_item_id   INTEGER NOT NULL REFERENCES inventory_items(id) ON DELETE CASCADE,
    movement_type       VARCHAR(50) NOT NULL CHECK (movement_type IN ('purchase', 'sale', 'transfer-in', 'transfer-out', 'adjustment')),
    quantity_delta      INTEGER NOT NULL CHECK (quantity_delta <> 0),
    occurred_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reference_type      VARCHAR(100),
    reference_id        VARCHAR(100),
    notes               TEXT,
    created_by          VARCHAR(100)

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

Indexes
10. marketplaces

Normalized list of supported marketplaces (Cardmarket, eBay, TCGPlayer, etc.).

```sql
CREATE TABLE marketplaces (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(50) NOT NULL UNIQUE,
    base_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);
```

CREATE INDEX idx_inventory_items_condition_id
    ON inventory_items(condition_id);

CREATE INDEX idx_inventory_items_quantity_on_hand
    ON inventory_items(quantity_on_hand);

CREATE INDEX idx_inventory_movements_item_occurred_at
    ON inventory_movements(inventory_item_id, occurred_at);

CREATE INDEX idx_inventory_movements_type_occurred_at
    ON inventory_movements(movement_type, occurred_at);


Inventory movement model

`inventory_items.quantity_on_hand` is treated as a synchronized aggregate derived from `inventory_movements.quantity_delta`. Stock changes should be recorded by inserting movements (purchase, sale, transfer-in, transfer-out, adjustment), not by directly updating `inventory_items.quantity_on_hand`.
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
    inventory_item_id INTEGER NOT NULL REFERENCES inventory_items(id) ON DELETE RESTRICT,
    language_id INTEGER REFERENCES languages(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_cost NUMERIC(12, 2) NOT NULL CHECK (unit_cost >= 0),
    fees NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (fees >= 0),
    shipping NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (shipping >= 0)
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
    inventory_item_id INTEGER NOT NULL REFERENCES inventory_items(id) ON DELETE RESTRICT,
    language_id INTEGER REFERENCES languages(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_sale_price NUMERIC(12, 2) NOT NULL CHECK (unit_sale_price >= 0),
    fees NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (fees >= 0),
    shipping NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (shipping >= 0)
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
11. external_listings

Generic listing model linked to inventory items.

```sql
CREATE TABLE external_listings (
    id SERIAL PRIMARY KEY,
    marketplace_id INTEGER NOT NULL REFERENCES marketplaces(id),
    inventory_item_id INTEGER NOT NULL REFERENCES inventory_items(id) ON DELETE CASCADE,
    external_listing_id VARCHAR(255) NOT NULL,
    listing_status VARCHAR(30) NOT NULL DEFAULT 'active',
    listed_price NUMERIC(12,2),
    currency CHAR(3),
    quantity_listed INTEGER,
    synced_at TIMESTAMPTZ,
    url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

Migration

Use `database/migrations/20260219_external_listings.sql` to create the normalized external listings model.
