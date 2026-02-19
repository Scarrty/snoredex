-- ============================================
-- SNOREDEX DATABASE SCHEMA
-- ============================================

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
    CONSTRAINT chk_sets_set_code_format CHECK (
        set_code IS NULL OR set_code ~ '^[A-Z0-9][A-Z0-9-]*$'
    ),
    era_id INTEGER REFERENCES eras(id)
);

CREATE UNIQUE INDEX uq_sets_business_key
    ON sets(name, COALESCE(set_code, ''));

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
    sort_number INTEGER
);

CREATE UNIQUE INDEX uq_card_prints_business_key
    ON card_prints(pokemon_id, set_id, card_number, COALESCE(type_id, -1));

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

CREATE TABLE inventory_movements (
    id SERIAL PRIMARY KEY,
    inventory_item_id INTEGER NOT NULL REFERENCES inventory_items(id) ON DELETE CASCADE,
    movement_type VARCHAR(50) NOT NULL CHECK (movement_type IN ('purchase', 'sale', 'transfer-in', 'transfer-out', 'adjustment')),
    quantity_delta INTEGER NOT NULL CHECK (quantity_delta <> 0),
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reference_type VARCHAR(100),
    reference_id VARCHAR(100),
    notes TEXT,
    created_by VARCHAR(100)

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

-- Compatibility view for existing cardmarket_listings consumers.
CREATE VIEW cardmarket_listings AS
SELECT
    el.id,
    el.inventory_card_print_id AS card_print_id,
    el.url,
    (el.listing_status IN ('active', 'paused') AND COALESCE(el.quantity_listed, 0) > 0) AS is_available
FROM external_listings el
JOIN marketplaces m ON m.id = el.marketplace_id
WHERE m.slug = 'cardmarket';

CREATE INDEX idx_inventory_items_card_print_id
    ON inventory_items(card_print_id);

CREATE INDEX idx_inventory_items_owner_location
    ON inventory_items(owner_id, location_id);

CREATE INDEX idx_inventory_items_condition_id
    ON inventory_items(condition_id);

CREATE INDEX idx_inventory_items_quantity_on_hand
    ON inventory_items(quantity_on_hand);

CREATE INDEX idx_inventory_movements_item_occurred_at
    ON inventory_movements(inventory_item_id, occurred_at);

CREATE INDEX idx_inventory_movements_type_occurred_at
    ON inventory_movements(movement_type, occurred_at);

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
BEGIN
    PERFORM set_config('snoredex.allow_quantity_sync', 'on', true);

    UPDATE inventory_items
    SET quantity_on_hand = quantity_on_hand + NEW.quantity_delta
    WHERE id = NEW.inventory_item_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'inventory_item % does not exist', NEW.inventory_item_id;
    END IF;

    RETURN NEW;
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
    currency VARCHAR(3) NOT NULL,
    notes TEXT
);

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

CREATE INDEX idx_acquisition_lines_acquisition_id
    ON acquisition_lines(acquisition_id);

CREATE INDEX idx_acquisition_lines_inventory
    ON acquisition_lines(card_print_id, owner_id, location_id);

CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    sold_at DATE NOT NULL,
    buyer_reference VARCHAR(255),
    channel VARCHAR(100),
    currency VARCHAR(3) NOT NULL,
    notes TEXT
);

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

CREATE INDEX idx_sales_lines_sale_id
    ON sales_lines(sale_id);

CREATE INDEX idx_sales_lines_inventory
    ON sales_lines(card_print_id, owner_id, location_id);

CREATE VIEW reporting_avg_acquisition_cost AS
SELECT
    al.card_print_id,
    al.owner_id,
    al.location_id,
    al.language_id,
    SUM(al.quantity) AS total_acquired_qty,
    CASE
        WHEN SUM(al.quantity) = 0 THEN 0
        ELSE SUM((al.quantity * al.unit_cost) + al.fees + al.shipping) / SUM(al.quantity)
    END AS avg_unit_cost
FROM acquisition_lines al
GROUP BY
    al.card_print_id,
    al.owner_id,
    al.location_id,
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
JOIN card_prints cp ON cp.id = sl.card_print_id
JOIN sets s ON s.id = cp.set_id
LEFT JOIN languages l ON l.id = sl.language_id
LEFT JOIN reporting_avg_acquisition_cost rac
    ON rac.card_print_id = sl.card_print_id
    AND rac.owner_id = sl.owner_id
    AND rac.location_id = sl.location_id
    AND (rac.language_id IS NOT DISTINCT FROM sl.language_id)
GROUP BY
    cp.id,
    s.id,
    s.name,
    COALESCE(l.id, 0),
    COALESCE(l.code, 'UNK'),
    COALESCE(l.name, 'Unknown');
CREATE INDEX idx_external_listings_marketplace_id
    ON external_listings(marketplace_id);

CREATE INDEX idx_external_listings_inventory_item
    ON external_listings(inventory_card_print_id, inventory_owner_id, inventory_location_id);

CREATE INDEX idx_external_listings_status
    ON external_listings(listing_status);
