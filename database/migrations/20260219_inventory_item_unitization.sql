-- SPDX-License-Identifier: CC-BY-NC-4.0
-- Database schema artifact licensed under CC BY-NC 4.0:
-- https://creativecommons.org/licenses/by-nc/4.0/

BEGIN;

DROP INDEX IF EXISTS uq_inventory_items_lot_condition_grade;

CREATE INDEX IF NOT EXISTS idx_inventory_items_unit_lookup
    ON inventory_items(
        card_print_id,
        user_id,
        location_id,
        condition_id,
        COALESCE(grade_provider, ''),
        COALESCE(grade_value, -1.0)
    );

ALTER TABLE inventory_items
    DROP CONSTRAINT IF EXISTS chk_inventory_items_unit_quantity_balance,
    DROP CONSTRAINT IF EXISTS chk_inventory_items_quantity_on_hand_check,
    DROP CONSTRAINT IF EXISTS chk_inventory_items_quantity_reserved_check,
    DROP CONSTRAINT IF EXISTS chk_inventory_items_quantity_damaged_check;

UPDATE inventory_items
SET quantity_on_hand = CASE WHEN quantity_on_hand > 0 THEN 1 ELSE 0 END,
    quantity_reserved = CASE WHEN quantity_reserved > 0 THEN 1 ELSE 0 END,
    quantity_damaged = CASE WHEN quantity_damaged > 0 THEN 1 ELSE 0 END
WHERE quantity_on_hand NOT IN (0, 1)
   OR quantity_reserved NOT IN (0, 1)
   OR quantity_damaged NOT IN (0, 1);

ALTER TABLE inventory_items
    ALTER COLUMN quantity_on_hand SET DEFAULT 1,
    ADD CONSTRAINT chk_inventory_items_quantity_on_hand_check
        CHECK (quantity_on_hand IN (0, 1)),
    ADD CONSTRAINT chk_inventory_items_quantity_reserved_check
        CHECK (quantity_reserved IN (0, 1)),
    ADD CONSTRAINT chk_inventory_items_quantity_damaged_check
        CHECK (quantity_damaged IN (0, 1)),
    ADD CONSTRAINT chk_inventory_items_unit_quantity_balance
        CHECK (quantity_reserved + quantity_damaged <= quantity_on_hand);

COMMIT;
