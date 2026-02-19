BEGIN;

CREATE TABLE IF NOT EXISTS marketplaces (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(50) NOT NULL UNIQUE,
    base_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

INSERT INTO marketplaces (name, slug, base_url)
VALUES ('Cardmarket', 'cardmarket', 'https://www.cardmarket.com')
ON CONFLICT (slug) DO NOTHING;

CREATE TABLE IF NOT EXISTS external_listings (
    id SERIAL PRIMARY KEY,
    marketplace_id INTEGER NOT NULL REFERENCES marketplaces(id),
    inventory_card_print_id INTEGER NOT NULL,
    inventory_owner_id INTEGER NOT NULL,
    inventory_location_id INTEGER NOT NULL,
    external_listing_id VARCHAR(255) NOT NULL,
    listing_status VARCHAR(30) NOT NULL DEFAULT 'active'
        CHECK (listing_status IN ('draft', 'active', 'paused', 'sold', 'ended', 'error')),
    listed_price NUMERIC(12,2) CHECK (listed_price >= 0),
    currency CHAR(3),
    quantity_listed INTEGER CHECK (quantity_listed >= 0),
    synced_at TIMESTAMPTZ,
    url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_external_listings_inventory_item
        FOREIGN KEY (inventory_card_print_id, inventory_owner_id, inventory_location_id)
        REFERENCES inventory_items(card_print_id, owner_id, location_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_external_listings_marketplace_listing_id
        UNIQUE (marketplace_id, external_listing_id)
);

CREATE INDEX IF NOT EXISTS idx_external_listings_marketplace_id
    ON external_listings(marketplace_id);

CREATE INDEX IF NOT EXISTS idx_external_listings_inventory_item
    ON external_listings(inventory_card_print_id, inventory_owner_id, inventory_location_id);

CREATE INDEX IF NOT EXISTS idx_external_listings_status
    ON external_listings(listing_status);

COMMIT;
