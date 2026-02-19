<!-- SPDX-License-Identifier: CC-BY-NC-4.0 -->
<!-- Database schema artifact licensed under CC BY-NC 4.0:
     https://creativecommons.org/licenses/by-nc/4.0/ -->

# Snoredex Database Schema

This document summarizes the normalized PostgreSQL schema defined in `database/schema.sql`.

## Design goals

- Keep card taxonomy normalized and extensible.
- Track unit-level inventory by owner, location, and condition.
- Enforce immutable stock movement history.
- Model acquisition and sales economics for reporting.
- Support external marketplace listing synchronization.

## Schema overview

### Core reference entities

- `users`: inventory owners / operators.
- `pokemon`: species master data.
- `eras`: set grouping eras.
- `sets`: TCG set metadata (`set_code`, optional `era_id`).
- `card_types`: print/variant typing.
- `card_prints`: unique prints by `(pokemon_id, set_id, card_number, type_id)`.
- `languages`: normalized language/locale codes.
- `card_print_languages`: many-to-many language availability per print.
- `locations`: physical/logical storage locations.
- `card_conditions`: condition reference data.

### Inventory & movement ledger

- `inventory_items`: unit inventory rows with owner/location/condition and optional grading.
- `inventory_movements`: immutable ledger of signed quantity deltas.

Key rules:

- `quantity_on_hand` is synchronized from movement inserts.
- Direct `quantity_on_hand` updates are blocked unless internal sync flag is set by trigger function.
- `inventory_movements` rows are immutable (update/delete blocked).
- Quantity cannot become negative.

### Marketplace integration

- `marketplaces`: configured marketplace providers.
- `external_listings`: marketplace listing records mapped to inventory items.
- `cardmarket_listings` view: compatibility projection for legacy Cardmarket consumers.

### Procurement & sales

- `acquisitions` + `acquisition_lines`: purchase headers/lines.
- `sales` + `sales_lines`: sales headers/lines.
- Both line tables link to `inventory_items`; optional `language_id` tracks language-level economics.

### Reporting views

- `reporting_avg_acquisition_cost`: weighted average acquisition cost by card/user/location/language.
- `reporting_profitability_by_card_set_language`: set/language profitability rollup from sales and acquisition costs.

## Constraints and quality checks

- Uppercase language code format enforcement.
- Currency format checks (`^[A-Z]{3}$`) across transactional/listing tables.
- Set code format checks.
- Grading pair and half-step range validation (`1.0` to `10.0`, 0.5 increments).
- Unique business keys for key dimensions and listing identity.

## Operational notes

- Source of truth: `database/schema.sql`.
- `update_timestamp()` and table triggers maintain `updated_at` on mutable tables.
- All table/column comments are embedded in SQL for schema self-documentation.

For relationships, see [`docs/er_diagram.md`](er_diagram.md).
