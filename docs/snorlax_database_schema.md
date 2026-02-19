Overview

This schema converts the flat Excel structure into a normalized relational database model.

Goals:

- Remove repetition (especially languages and sets)
- Support future Pokémon additions
- Support multiple print variations
- Maintain marketplace references
- Enable multilingual release tracking
- Support multiple external marketplaces with one listing model

Entity Relationship Overview

Pokemon ──< CardPrint >── Set
                   │
                   ├──< InventoryItem >──< ExternalListing >── Marketplace
                   │
                   └──< CardPrintLanguage >── Language

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

9. inventory_items

Tracks per-print inventory by owner and location.

```sql
CREATE TABLE inventory_items (
    card_print_id       INTEGER NOT NULL REFERENCES card_prints(id) ON DELETE CASCADE,
    owner_id            INTEGER NOT NULL,
    location_id         INTEGER NOT NULL REFERENCES locations(id),
    quantity_on_hand    INTEGER NOT NULL DEFAULT 0 CHECK (quantity_on_hand >= 0),
    quantity_reserved   INTEGER NOT NULL DEFAULT 0 CHECK (quantity_reserved >= 0),
    quantity_damaged    INTEGER NOT NULL DEFAULT 0 CHECK (quantity_damaged >= 0),
    PRIMARY KEY (card_print_id, owner_id, location_id)
);
```

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

11. external_listings

Generic listing model linked to inventory items.

```sql
CREATE TABLE external_listings (
    id SERIAL PRIMARY KEY,
    marketplace_id INTEGER NOT NULL REFERENCES marketplaces(id),
    inventory_card_print_id INTEGER NOT NULL,
    inventory_owner_id INTEGER NOT NULL,
    inventory_location_id INTEGER NOT NULL,
    external_listing_id VARCHAR(255) NOT NULL,
    listing_status VARCHAR(30) NOT NULL DEFAULT 'active',
    listed_price NUMERIC(12,2),
    currency CHAR(3),
    quantity_listed INTEGER,
    synced_at TIMESTAMPTZ,
    url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    FOREIGN KEY (inventory_card_print_id, inventory_owner_id, inventory_location_id)
        REFERENCES inventory_items(card_print_id, owner_id, location_id)
);
```

12. cardmarket_listings (compatibility view)

Legacy read model maintained as a view to avoid breaking existing queries.

```sql
CREATE VIEW cardmarket_listings AS
SELECT
    el.id,
    el.inventory_card_print_id AS card_print_id,
    el.url,
    (el.listing_status IN ('active', 'paused') AND COALESCE(el.quantity_listed, 0) > 0) AS is_available
FROM external_listings el
JOIN marketplaces m ON m.id = el.marketplace_id
WHERE m.slug = 'cardmarket';
```

Migration

Use `database/migrations/20260219_external_listings.sql` to migrate from a physical
`cardmarket_listings` table to the normalized model and recreate `cardmarket_listings`
as a compatibility view.
