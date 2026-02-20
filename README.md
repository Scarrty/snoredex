<!-- SPDX-License-Identifier: CC-BY-NC-4.0 -->
# 💤 Snoredex

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Relational_DB-336791?logo=postgresql&logoColor=white)
![Normalized](https://img.shields.io/badge/Schema-3NF-blue)
![Status](https://img.shields.io/badge/Status-Active-success)
![License](https://img.shields.io/badge/License-CC_BY--NC_4.0-orange)
![Snorlax](https://img.shields.io/badge/Pokémon-Snorlax-3b4cca)

## 📘 Project Overview

Snoredex is a normalized PostgreSQL schema for tracking Snorlax TCG card prints, unit inventory, acquisitions/sales economics, and external marketplace listings.

The repository now includes a monorepo web-application scaffold that follows the implementation plan in `docs/web_app_implementation_plan.md`:

- `apps/api`: NestJS API skeleton with Prisma wiring and `/api/v1/health`.
- `apps/web`: Next.js App Router skeleton with route scaffolds for MVP pages.
- `packages/api-contract`: placeholder for shared contracts.
- `packages/eslint-config`: placeholder for shared lint config.
- `docker-compose.yml`: local Postgres + app containers.

## 🧠 Schema highlights

- **Immutable stock ledger:** `inventory_movements` cannot be updated/deleted. `quantity_on_hand` is synchronized by triggers.
- **Unit-level inventory discipline:** inventory rows represent unit cards (`quantity_on_hand`, `quantity_reserved`, `quantity_damaged` constrained to 0/1).
- **Data quality constraints:** language codes, currency codes, set code format, listing uniqueness, and grade pairing/range are validated in-schema.
- **Reporting-ready:** built-in views support weighted acquisition cost and realized profitability rollups.

## 🚀 Quick Start

1. Start PostgreSQL and initialize from `database/schema.sql`:
   ```bash
   docker compose up -d postgres
   ```
2. Install workspace dependencies:
   ```bash
   corepack enable
   pnpm install
   ```
3. Run both apps:
   ```bash
   pnpm dev
   ```
4. Open:
   - Web: `http://localhost:3000`
   - API health endpoint: `http://localhost:3001/api/v1/health`

## 🗺 Database ER Diagram

The maintained ER diagram lives in [`docs/er_diagram.md`](docs/er_diagram.md).

## 📚 Documentation

- [`docs/snorlax_database_schema.md`](docs/snorlax_database_schema.md): complete table-by-table schema documentation
- [`docs/er_diagram.md`](docs/er_diagram.md): Mermaid ER diagram aligned to the SQL schema
- [`docs/snorlax.md`](docs/snorlax.md): source spreadsheet structure (`snorlax_incl jp.xlsx`)
- [`database/schema.sql`](database/schema.sql): source of truth DDL, triggers, views, and comments
- [`docs/web_app_implementation_plan.md`](docs/web_app_implementation_plan.md): execution plan for API + web buildout

## ⚖️ Licensing

The Snoredex project is licensed under **CC BY-NC 4.0** (Attribution-NonCommercial 4.0 International).

This license applies to the repository contents unless a file explicitly states otherwise.

See [`LICENSE-DB-SCHEMA-CC-BY-NC-4.0.md`](LICENSE-DB-SCHEMA-CC-BY-NC-4.0.md) for details.
