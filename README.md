# 💤 Snoredex

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Relational_DB-336791?logo=postgresql&logoColor=white)
![Normalized](https://img.shields.io/badge/Schema-3NF-blue)
![Status](https://img.shields.io/badge/Status-Active-success)
![License](https://img.shields.io/badge/Schema_License-CC_BY--NC_4.0-orange)
![Snorlax](https://img.shields.io/badge/Pokémon-Snorlax-3b4cca)

## 📘 Project Overview

Snoredex is a normalized PostgreSQL schema for tracking Snorlax TCG prints, inventory, procurement/sales activity, and marketplace listings.

The schema is designed for:

- Collection tracking
- Inventory movement ledgering
- Procurement and sales profitability reporting
- Marketplace synchronization
- Multilingual release tracking

Marketplace support is normalized via:

- `marketplaces` (Cardmarket, eBay, TCGPlayer, etc.)
- `external_listings` linked to inventory items


## ⚖️ Licensing

The Snoredex **database schema artifacts** are licensed under **CC BY-NC 4.0** (Attribution-NonCommercial 4.0 International).

Covered artifacts include:

- `database/schema.sql`
- `database/migrations/`
- `docs/snorlax_database_schema.md`
- `docs/er_diagram.md`

See [`LICENSE-DB-SCHEMA-CC-BY-NC-4.0.md`](LICENSE-DB-SCHEMA-CC-BY-NC-4.0.md) for details.

## 🗺 Database ER Diagram

```mermaid
erDiagram
    POKEMON ||--o{ CARD_PRINTS : has
    SETS ||--o{ CARD_PRINTS : contains
    ERAS ||--o{ SETS : categorizes
    CARD_TYPES ||--o{ CARD_PRINTS : classifies
    CARD_PRINTS ||--o{ CARD_PRINT_LANGUAGES : printed_in
    LANGUAGES ||--o{ CARD_PRINT_LANGUAGES : available_as

    CARD_PRINTS ||--o{ INVENTORY_ITEMS : stocked_as
    LOCATIONS ||--o{ INVENTORY_ITEMS : stores
    CARD_CONDITIONS ||--o{ INVENTORY_ITEMS : conditions
    INVENTORY_ITEMS ||--o{ INVENTORY_MOVEMENTS : moves_through

    INVENTORY_ITEMS ||--o{ ACQUISITION_LINES : procured_as
    ACQUISITIONS ||--o{ ACQUISITION_LINES : has
    INVENTORY_ITEMS ||--o{ SALES_LINES : sold_from
    SALES ||--o{ SALES_LINES : has

    MARKETPLACES ||--o{ EXTERNAL_LISTINGS : hosts
    INVENTORY_ITEMS ||--o{ EXTERNAL_LISTINGS : listed_as
```
