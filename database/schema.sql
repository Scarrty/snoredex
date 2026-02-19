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
    id SERIAL PRIMARY KEY,
    card_print_id INTEGER NOT NULL REFERENCES card_prints(id) ON DELETE CASCADE,
    owner_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL REFERENCES locations(id),
    quantity_on_hand INTEGER NOT NULL DEFAULT 0 CHECK (quantity_on_hand >= 0),
    quantity_reserved INTEGER NOT NULL DEFAULT 0 CHECK (quantity_reserved >= 0),
    quantity_damaged INTEGER NOT NULL DEFAULT 0 CHECK (quantity_damaged >= 0),
    UNIQUE (card_print_id, owner_id, location_id)
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

CREATE INDEX idx_inventory_items_card_print_id
    ON inventory_items(card_print_id);

CREATE INDEX idx_inventory_items_owner_location
    ON inventory_items(owner_id, location_id);

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
