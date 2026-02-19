# 💤 Snoredex

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Relational_DB-336791?logo=postgresql&logoColor=white)
![Normalized](https://img.shields.io/badge/Schema-3NF-blue)
![Status](https://img.shields.io/badge/Status-Active-success)
![License](https://img.shields.io/badge/Schema_License-CC_BY--NC_4.0-orange)
![Snorlax](https://img.shields.io/badge/Pokémon-Snorlax-3b4cca)

## 📘 Project Overview

Snoredex is a normalized PostgreSQL schema for tracking Snorlax TCG card prints, unit inventory, acquisitions/sales economics, and external marketplace listings.

The current schema includes:

- Core card taxonomy (`pokemon`, `eras`, `sets`, `card_types`, `card_prints`)
- Print language availability (`languages`, `card_print_languages`)
- User-owned, condition-aware inventory (`users`, `inventory_items`, `locations`, `card_conditions`)
- Immutable movement ledger with quantity synchronization (`inventory_movements` + trigger/functions)
- Procurement and sales documents (`acquisitions`, `acquisition_lines`, `sales`, `sales_lines`)
- Marketplace integrations (`marketplaces`, `external_listings`, `cardmarket_listings` compatibility view)
- Reporting views for average acquisition cost and profitability by card/set/language

## 🧠 Schema highlights

- **Immutable stock ledger:** `inventory_movements` cannot be updated/deleted. `quantity_on_hand` is synchronized by triggers.
- **Unit-level inventory discipline:** inventory rows represent unit cards (`quantity_on_hand`, `quantity_reserved`, `quantity_damaged` constrained to 0/1).
- **Data quality constraints:** language codes, currency codes, set code format, listing uniqueness, and grade pairing/range are validated in-schema.
- **Reporting-ready:** built-in views support weighted acquisition cost and realized profitability rollups.

## 🗺 Database ER Diagram

The maintained ER diagram lives in [`docs/er_diagram.md`](docs/er_diagram.md).

## 📚 Documentation

- [`docs/snorlax_database_schema.md`](docs/snorlax_database_schema.md): complete table-by-table schema documentation
- [`docs/er_diagram.md`](docs/er_diagram.md): Mermaid ER diagram aligned to the SQL schema
- [`docs/snorlax.md`](docs/snorlax.md): source spreadsheet structure (`snorlax_incl jp.xlsx`)
- [`database/schema.sql`](database/schema.sql): source of truth DDL, triggers, views, and comments

## ⚖️ Licensing

The Snoredex **database schema artifacts** are licensed under **CC BY-NC 4.0** (Attribution-NonCommercial 4.0 International).

Covered artifacts include:

- `database/schema.sql`
- `docs/snorlax_database_schema.md`
- `docs/er_diagram.md`

See [`LICENSE-DB-SCHEMA-CC-BY-NC-4.0.md`](LICENSE-DB-SCHEMA-CC-BY-NC-4.0.md) for details.
