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
