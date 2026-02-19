-- SPDX-License-Identifier: CC-BY-NC-4.0
-- Database schema artifact licensed under CC BY-NC 4.0:
-- https://creativecommons.org/licenses/by-nc/4.0/

-- ============================================
-- SNOREDEX DATABASE SCHEMA
-- ============================================

-- Generic timestamp updater for mutable tables.
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE owners (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    display_name VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_owners_set_updated_at
BEFORE UPDATE ON owners
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TABLE pokemon (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    national_dex_no INTEGER
);

CREATE UNIQUE INDEX uq_pokemon_name
    ON pokemon(name);

CREATE UNIQUE INDEX uq_pokemon_national_dex_no
    ON pokemon(national_dex_no)
    WHERE national_dex_no IS NOT NULL;

CREATE TABLE eras (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE UNIQUE INDEX uq_eras_name
    ON eras(name);

CREATE TABLE sets (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    set_code VARCHAR(20),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_sets_set_code_format CHECK (
        set_code IS NULL OR set_code ~ '^[A-Z0-9][A-Z0-9-]*$'
    ),
    era_id INTEGER REFERENCES eras(id)
);

CREATE UNIQUE INDEX uq_sets_business_key
    ON sets(name, COALESCE(set_code, ''));

CREATE INDEX idx_sets_era_id
    ON sets(era_id);

CREATE TRIGGER trg_sets_set_updated_at
BEFORE UPDATE ON sets
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TABLE card_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE UNIQUE INDEX uq_card_types_name
    ON card_types(name);

CREATE TABLE card_prints (
    id SERIAL PRIMARY KEY,
    pokemon_id INTEGER NOT NULL REFERENCES pokemon(id),
    set_id INTEGER NOT NULL REFERENCES sets(id),
    card_number VARCHAR(50) NOT NULL,
    type_id INTEGER REFERENCES card_types(id),
    sort_number INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX uq_card_prints_business_key
    ON card_prints(pokemon_id, set_id, card_number, COALESCE(type_id, -1));

CREATE INDEX idx_card_prints_pokemon_id
    ON card_prints(pokemon_id);

CREATE INDEX idx_card_prints_set_id
    ON card_prints(set_id);

CREATE TRIGGER trg_card_prints_set_updated_at
BEFORE UPDATE ON card_prints
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TABLE languages (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    CONSTRAINT chk_languages_code_uppercase CHECK (code = UPPER(code)),
    CONSTRAINT chk_languages_code_format CHECK (code ~ '^[A-Z]{2,3}(-[A-Z0-9]{2,8})*$'),
    name VARCHAR(100) NOT NULL
);

CREATE TABLE card_print_languages (
    card_print_id INTEGER REFERENCES card_prints(id) ON DELETE CASCADE,
    language_id INTEGER REFERENCES languages(id) ON DELETE CASCADE,
    PRIMARY KEY (card_print_id, language_id)
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
    owner_id INTEGER NOT NULL REFERENCES owners(id),
    location_id INTEGER NOT NULL REFERENCES locations(id),
    condition_id INTEGER NOT NULL REFERENCES card_conditions(id),
    grade_provider VARCHAR(100),
    grade_value NUMERIC(3,1),
    quantity_on_hand INTEGER NOT NULL DEFAULT 1 CHECK (quantity_on_hand IN (0, 1)),
    quantity_reserved INTEGER NOT NULL DEFAULT 0 CHECK (quantity_reserved IN (0, 1)),
    quantity_damaged INTEGER NOT NULL DEFAULT 0 CHECK (quantity_damaged IN (0, 1)),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
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
        ),
    CONSTRAINT chk_inventory_items_unit_quantity_balance
        CHECK (quantity_reserved + quantity_damaged <= quantity_on_hand)
);

CREATE INDEX idx_inventory_items_unit_lookup
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

CREATE INDEX idx_inventory_items_owner_id
    ON inventory_items(owner_id);

CREATE INDEX idx_inventory_items_condition_id
    ON inventory_items(condition_id);

CREATE INDEX idx_inventory_items_quantity_on_hand
    ON inventory_items(quantity_on_hand);

CREATE TRIGGER trg_inventory_items_set_updated_at
BEFORE UPDATE ON inventory_items
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TABLE inventory_movements (
    id SERIAL PRIMARY KEY,
    inventory_item_id INTEGER NOT NULL REFERENCES inventory_items(id) ON DELETE CASCADE,
    movement_type VARCHAR(50) NOT NULL,
    quantity_delta INTEGER NOT NULL CHECK (quantity_delta <> 0),
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reference_type VARCHAR(100),
    reference_id VARCHAR(100),
    notes TEXT,
    created_by VARCHAR(100),
    CONSTRAINT chk_inventory_movements_movement_type
        CHECK (movement_type IN ('purchase', 'sale', 'transfer-in', 'transfer-out', 'adjustment'))
);

CREATE INDEX idx_inventory_movements_item_occurred_at
    ON inventory_movements(inventory_item_id, occurred_at);

CREATE INDEX idx_inventory_movements_type_occurred_at
    ON inventory_movements(movement_type, occurred_at);

CREATE TABLE marketplaces (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(50) NOT NULL UNIQUE,
    base_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE external_listings (
    id SERIAL PRIMARY KEY,
    marketplace_id INTEGER NOT NULL REFERENCES marketplaces(id),
    inventory_item_id INTEGER NOT NULL REFERENCES inventory_items(id) ON DELETE CASCADE,
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
    CONSTRAINT chk_external_listings_currency_format
        CHECK (currency IS NULL OR currency ~ '^[A-Z]{3}$'),
    CONSTRAINT uq_external_listings_marketplace_listing_id
        UNIQUE (marketplace_id, external_listing_id)
);

CREATE INDEX idx_external_listings_marketplace_id
    ON external_listings(marketplace_id);

CREATE INDEX idx_external_listings_inventory_item
    ON external_listings(inventory_item_id);

CREATE INDEX idx_external_listings_status
    ON external_listings(listing_status);

CREATE TRIGGER trg_external_listings_set_updated_at
BEFORE UPDATE ON external_listings
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

-- Compatibility view for existing cardmarket_listings consumers.
CREATE VIEW cardmarket_listings AS
SELECT
    el.id,
    ii.card_print_id,
    el.url,
    el.updated_at,
    (el.listing_status IN ('active', 'paused') AND COALESCE(el.quantity_listed, 0) > 0) AS is_available
FROM external_listings el
JOIN inventory_items ii ON ii.id = el.inventory_item_id
JOIN marketplaces m ON m.id = el.marketplace_id
WHERE m.slug = 'cardmarket';

CREATE OR REPLACE FUNCTION enforce_inventory_item_quantity_writes()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.quantity_on_hand <> OLD.quantity_on_hand
        AND current_setting('snoredex.allow_quantity_sync', true) IS DISTINCT FROM 'on' THEN
        RAISE EXCEPTION 'quantity_on_hand is synchronized from inventory_movements; insert a movement instead of updating quantity_on_hand directly';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_enforce_inventory_item_quantity_writes
BEFORE UPDATE OF quantity_on_hand ON inventory_items
FOR EACH ROW
EXECUTE FUNCTION enforce_inventory_item_quantity_writes();

CREATE OR REPLACE FUNCTION apply_inventory_movement_delta()
RETURNS TRIGGER AS $$
DECLARE
    v_current_qty INTEGER;
    v_new_qty INTEGER;
BEGIN
    PERFORM set_config('snoredex.allow_quantity_sync', 'on', true);

    SELECT quantity_on_hand
    INTO v_current_qty
    FROM inventory_items
    WHERE id = NEW.inventory_item_id
    FOR UPDATE;

    IF NOT FOUND THEN
        PERFORM set_config('snoredex.allow_quantity_sync', 'off', true);
        RAISE EXCEPTION 'Cannot apply movement: inventory_item % does not exist.', NEW.inventory_item_id;
    END IF;

    v_new_qty := v_current_qty + NEW.quantity_delta;

    IF v_new_qty < 0 THEN
        PERFORM set_config('snoredex.allow_quantity_sync', 'off', true);
        RAISE EXCEPTION
            'Cannot apply movement % to inventory_item %: current quantity %, resulting quantity % would be negative.',
            NEW.id,
            NEW.inventory_item_id,
            v_current_qty,
            v_new_qty;
    END IF;

    UPDATE inventory_items
    SET quantity_on_hand = v_new_qty
    WHERE id = NEW.inventory_item_id;

    PERFORM set_config('snoredex.allow_quantity_sync', 'off', true);

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        PERFORM set_config('snoredex.allow_quantity_sync', 'off', true);
        RAISE;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_apply_inventory_movement_delta
AFTER INSERT ON inventory_movements
FOR EACH ROW
EXECUTE FUNCTION apply_inventory_movement_delta();

CREATE OR REPLACE FUNCTION prevent_inventory_movement_mutation()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'inventory_movements are immutable; create a compensating movement instead of %', TG_OP;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_inventory_movement_update
BEFORE UPDATE ON inventory_movements
FOR EACH ROW
EXECUTE FUNCTION prevent_inventory_movement_mutation();

CREATE TRIGGER trg_prevent_inventory_movement_delete
BEFORE DELETE ON inventory_movements
FOR EACH ROW
EXECUTE FUNCTION prevent_inventory_movement_mutation();

CREATE OR REPLACE FUNCTION record_inventory_movement(
    p_inventory_item_id INTEGER,
    p_movement_type VARCHAR,
    p_quantity_delta INTEGER,
    p_occurred_at TIMESTAMPTZ DEFAULT NOW(),
    p_reference_type VARCHAR DEFAULT NULL,
    p_reference_id VARCHAR DEFAULT NULL,
    p_notes TEXT DEFAULT NULL,
    p_created_by VARCHAR DEFAULT NULL
)
RETURNS inventory_movements AS $$
DECLARE
    v_row inventory_movements;
BEGIN
    INSERT INTO inventory_movements (
        inventory_item_id,
        movement_type,
        quantity_delta,
        occurred_at,
        reference_type,
        reference_id,
        notes,
        created_by
    )
    VALUES (
        p_inventory_item_id,
        p_movement_type,
        p_quantity_delta,
        p_occurred_at,
        p_reference_type,
        p_reference_id,
        p_notes,
        p_created_by
    )
    RETURNING * INTO v_row;

    RETURN v_row;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE acquisitions (
    id SERIAL PRIMARY KEY,
    acquired_at DATE NOT NULL,
    supplier_reference VARCHAR(255),
    channel VARCHAR(100),
    currency CHAR(3) NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_acquisitions_currency_format
        CHECK (currency IS NULL OR currency ~ '^[A-Z]{3}$')
);

CREATE TRIGGER trg_acquisitions_set_updated_at
BEFORE UPDATE ON acquisitions
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TABLE acquisition_lines (
    id SERIAL PRIMARY KEY,
    acquisition_id INTEGER NOT NULL REFERENCES acquisitions(id) ON DELETE CASCADE,
    inventory_item_id INTEGER NOT NULL REFERENCES inventory_items(id) ON DELETE RESTRICT,
    language_id INTEGER REFERENCES languages(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_cost NUMERIC(12, 2) NOT NULL CHECK (unit_cost >= 0),
    fees NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (fees >= 0),
    shipping NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (shipping >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_acquisition_lines_acquisition_id
    ON acquisition_lines(acquisition_id);

CREATE INDEX idx_acquisition_lines_inventory
    ON acquisition_lines(inventory_item_id);

CREATE TRIGGER trg_acquisition_lines_set_updated_at
BEFORE UPDATE ON acquisition_lines
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    sold_at DATE NOT NULL,
    buyer_reference VARCHAR(255),
    channel VARCHAR(100),
    currency CHAR(3) NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_sales_currency_format
        CHECK (currency IS NULL OR currency ~ '^[A-Z]{3}$')
);

CREATE TRIGGER trg_sales_set_updated_at
BEFORE UPDATE ON sales
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TABLE sales_lines (
    id SERIAL PRIMARY KEY,
    sale_id INTEGER NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
    inventory_item_id INTEGER NOT NULL REFERENCES inventory_items(id) ON DELETE RESTRICT,
    language_id INTEGER REFERENCES languages(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_sale_price NUMERIC(12, 2) NOT NULL CHECK (unit_sale_price >= 0),
    fees NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (fees >= 0),
    shipping NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (shipping >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sales_lines_sale_id
    ON sales_lines(sale_id);

CREATE INDEX idx_sales_lines_inventory
    ON sales_lines(inventory_item_id);

CREATE TRIGGER trg_sales_lines_set_updated_at
BEFORE UPDATE ON sales_lines
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

-- Optional normalized currency lookup table. Keep commented while CHAR(3)+CHECK remains default.
-- CREATE TABLE currencies (
--     code CHAR(3) PRIMARY KEY,
--     name VARCHAR(100) NOT NULL,
--     symbol VARCHAR(10),
--     is_active BOOLEAN NOT NULL DEFAULT TRUE,
--     created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
--     updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
--     CONSTRAINT chk_currencies_code_format CHECK (code ~ '^[A-Z]{3}$')
-- );
--
-- CREATE TRIGGER trg_currencies_set_updated_at
-- BEFORE UPDATE ON currencies
-- FOR EACH ROW
-- EXECUTE FUNCTION update_timestamp();
--
-- ALTER TABLE acquisitions
--     ADD CONSTRAINT fk_acquisitions_currency
--     FOREIGN KEY (currency) REFERENCES currencies(code);
--
-- ALTER TABLE sales
--     ADD CONSTRAINT fk_sales_currency
--     FOREIGN KEY (currency) REFERENCES currencies(code);
--
-- ALTER TABLE external_listings
--     ADD CONSTRAINT fk_external_listings_currency
--     FOREIGN KEY (currency) REFERENCES currencies(code);

CREATE VIEW reporting_avg_acquisition_cost AS
SELECT
    ii.card_print_id,
    ii.owner_id,
    ii.location_id,
    al.language_id,
    SUM(al.quantity) AS total_acquired_qty,
    CASE
        WHEN SUM(al.quantity) = 0 THEN 0
        ELSE SUM((al.quantity * al.unit_cost) + al.fees + al.shipping) / SUM(al.quantity)
    END AS avg_unit_cost
FROM acquisition_lines al
JOIN inventory_items ii ON ii.id = al.inventory_item_id
GROUP BY
    ii.card_print_id,
    ii.owner_id,
    ii.location_id,
    al.language_id;

CREATE VIEW reporting_profitability_by_card_set_language AS
SELECT
    cp.id AS card_print_id,
    s.id AS set_id,
    s.name AS set_name,
    COALESCE(l.id, 0) AS language_id,
    COALESCE(l.code, 'UNK') AS language_code,
    COALESCE(l.name, 'Unknown') AS language_name,
    SUM(sl.quantity) AS sold_quantity,
    SUM(sl.quantity * sl.unit_sale_price) AS gross_revenue,
    SUM(sl.quantity * COALESCE(rac.avg_unit_cost, 0)) AS cogs,
    SUM(sl.quantity * sl.unit_sale_price) - SUM(sl.quantity * COALESCE(rac.avg_unit_cost, 0)) AS gross_margin,
    SUM((sl.quantity * sl.unit_sale_price) - sl.fees - sl.shipping)
        - SUM(sl.quantity * COALESCE(rac.avg_unit_cost, 0)) AS realized_profit
FROM sales_lines sl
JOIN inventory_items ii ON ii.id = sl.inventory_item_id
JOIN card_prints cp ON cp.id = ii.card_print_id
JOIN sets s ON s.id = cp.set_id
LEFT JOIN languages l ON l.id = sl.language_id
LEFT JOIN reporting_avg_acquisition_cost rac
    ON rac.card_print_id = ii.card_print_id
    AND rac.owner_id = ii.owner_id
    AND rac.location_id = ii.location_id
    AND (rac.language_id IS NOT DISTINCT FROM sl.language_id)
GROUP BY
    cp.id,
    s.id,
    s.name,
    COALESCE(l.id, 0),
    COALESCE(l.code, 'UNK'),
    COALESCE(l.name, 'Unknown');

COMMENT ON TABLE owners IS 'Account owners/users who own inventory and business transactions.';
COMMENT ON COLUMN owners.id IS 'Primary key for owner accounts.';
COMMENT ON COLUMN owners.username IS 'Unique owner login/handle.';
COMMENT ON COLUMN owners.email IS 'Optional unique email address for the owner account.';
COMMENT ON COLUMN owners.display_name IS 'Human-friendly name shown in interfaces and reports.';

COMMENT ON TABLE pokemon IS 'Pokémon master records used to group printed cards.';
COMMENT ON COLUMN pokemon.id IS 'Primary key for Pokémon.';
COMMENT ON COLUMN pokemon.national_dex_no IS 'Optional National Pokédex number used as a stable external identifier.';

COMMENT ON TABLE eras IS 'High-level release eras used for grouping card sets.';
COMMENT ON COLUMN eras.id IS 'Primary key for set eras.';

COMMENT ON TABLE sets IS 'Pokémon TCG sets/expansions.';
COMMENT ON COLUMN sets.id IS 'Primary key for sets.';
COMMENT ON COLUMN sets.era_id IS 'Foreign key to eras for era-level grouping and reporting.';

COMMENT ON TABLE card_types IS 'Reference table for card print variants/types.';
COMMENT ON COLUMN card_types.id IS 'Primary key for card types.';

COMMENT ON TABLE card_prints IS 'Specific printable card variants within a set.';
COMMENT ON COLUMN card_prints.id IS 'Primary key for a card print.';
COMMENT ON COLUMN card_prints.pokemon_id IS 'Foreign key to pokemon represented by this print.';
COMMENT ON COLUMN card_prints.set_id IS 'Foreign key to the set this print belongs to.';
COMMENT ON COLUMN card_prints.type_id IS 'Optional foreign key to card type for variant differentiation.';

COMMENT ON TABLE languages IS 'Supported card languages and locale identifiers.';
COMMENT ON COLUMN languages.id IS 'Primary key for languages.';
COMMENT ON COLUMN languages.code IS 'Uppercase language code such as EN or EN-US.';

COMMENT ON TABLE card_print_languages IS 'Many-to-many mapping of which card prints exist in which languages.';
COMMENT ON COLUMN card_print_languages.card_print_id IS 'Foreign key to card_prints.';
COMMENT ON COLUMN card_print_languages.language_id IS 'Foreign key to languages.';

COMMENT ON TABLE locations IS 'Storage locations where inventory can be kept.';
COMMENT ON COLUMN locations.id IS 'Primary key for inventory locations.';

COMMENT ON TABLE card_conditions IS 'Condition grading reference values for physical card state.';
COMMENT ON COLUMN card_conditions.id IS 'Primary key for card condition values.';
COMMENT ON COLUMN card_conditions.code IS 'Unique short code representing condition.';

COMMENT ON TABLE inventory_items IS 'Physical inventory units and ownership/location context.';
COMMENT ON COLUMN inventory_items.id IS 'Primary key for an inventory item.';
COMMENT ON COLUMN inventory_items.card_print_id IS 'Foreign key to the represented card print.';
COMMENT ON COLUMN inventory_items.owner_id IS 'Foreign key to owners who own this inventory item.';
COMMENT ON COLUMN inventory_items.location_id IS 'Foreign key to storage location of this inventory item.';
COMMENT ON COLUMN inventory_items.condition_id IS 'Foreign key to card condition for this inventory item.';
COMMENT ON COLUMN inventory_items.quantity_on_hand IS 'Synchronized quantity; maintained by immutable inventory movements.';

COMMENT ON TABLE inventory_movements IS 'Immutable ledger of stock movements applied to inventory items.';
COMMENT ON COLUMN inventory_movements.id IS 'Primary key for an inventory movement event.';
COMMENT ON COLUMN inventory_movements.inventory_item_id IS 'Foreign key to the impacted inventory item.';
COMMENT ON COLUMN inventory_movements.movement_type IS 'Movement reason category; constrained by CHECK (candidate for enum later).';
COMMENT ON COLUMN inventory_movements.quantity_delta IS 'Signed quantity change applied atomically to quantity_on_hand.';

COMMENT ON TABLE marketplaces IS 'Configured external marketplaces for listings sync.';
COMMENT ON COLUMN marketplaces.id IS 'Primary key for marketplaces.';
COMMENT ON COLUMN marketplaces.slug IS 'Unique machine slug used in integrations and compatibility views.';

COMMENT ON TABLE external_listings IS 'Marketplace listings mapped to local inventory items.';
COMMENT ON COLUMN external_listings.id IS 'Primary key for external listing records.';
COMMENT ON COLUMN external_listings.marketplace_id IS 'Foreign key to marketplaces.';
COMMENT ON COLUMN external_listings.inventory_item_id IS 'Foreign key to inventory_items represented in the listing.';
COMMENT ON COLUMN external_listings.currency IS 'ISO 4217-style uppercase 3-letter listing currency code.';

COMMENT ON TABLE acquisitions IS 'Acquisition headers representing card purchases/imports.';
COMMENT ON COLUMN acquisitions.id IS 'Primary key for acquisition documents.';
COMMENT ON COLUMN acquisitions.currency IS 'ISO 4217-style uppercase 3-letter acquisition currency code.';

COMMENT ON TABLE acquisition_lines IS 'Line-level purchased inventory quantities and costs.';
COMMENT ON COLUMN acquisition_lines.id IS 'Primary key for acquisition lines.';
COMMENT ON COLUMN acquisition_lines.acquisition_id IS 'Foreign key to acquisition header.';
COMMENT ON COLUMN acquisition_lines.inventory_item_id IS 'Foreign key to acquired inventory item.';

COMMENT ON TABLE sales IS 'Sales headers representing card sales transactions.';
COMMENT ON COLUMN sales.id IS 'Primary key for sales documents.';
COMMENT ON COLUMN sales.currency IS 'ISO 4217-style uppercase 3-letter sales currency code.';

COMMENT ON TABLE sales_lines IS 'Line-level sold inventory quantities and sale pricing.';
COMMENT ON COLUMN sales_lines.id IS 'Primary key for sales lines.';
COMMENT ON COLUMN sales_lines.sale_id IS 'Foreign key to sales header.';
COMMENT ON COLUMN sales_lines.inventory_item_id IS 'Foreign key to sold inventory item.';
