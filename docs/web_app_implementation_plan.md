# Web App Implementation Plan (NestJS + Prisma + Next.js + PostgreSQL)

This plan turns the existing Snoredex PostgreSQL schema into a production-ready web application.

## 1) Recommended Repository Structure

Use a monorepo so API and web share contracts/types while deploying independently.

```text
snoredex/
├─ apps/
│  ├─ api/                          # NestJS backend
│  │  ├─ src/
│  │  │  ├─ main.ts
│  │  │  ├─ app.module.ts
│  │  │  ├─ common/                 # guards, pipes, filters, interceptors
│  │  │  ├─ config/                 # env + typed config
│  │  │  ├─ prisma/
│  │  │  │  ├─ prisma.module.ts
│  │  │  │  └─ prisma.service.ts
│  │  │  ├─ auth/                   # JWT auth, users, roles
│  │  │  ├─ catalog/                # pokemon, eras, sets, card_types, card_prints
│  │  │  ├─ inventory/              # inventory_items, inventory_movements, locations
│  │  │  ├─ transactions/           # acquisitions/sales + lines
│  │  │  ├─ marketplaces/           # marketplaces, external_listings
│  │  │  └─ reports/                # reporting views endpoints
│  │  ├─ prisma/
│  │  │  ├─ schema.prisma
│  │  │  ├─ migrations/
│  │  │  └─ seed.ts
│  │  ├─ test/                      # integration/e2e tests
│  │  ├─ package.json
│  │  └─ tsconfig.json
│  ├─ web/                          # Next.js frontend (App Router)
│  │  ├─ src/
│  │  │  ├─ app/
│  │  │  │  ├─ (auth)/login/page.tsx
│  │  │  │  ├─ dashboard/page.tsx
│  │  │  │  ├─ catalog/...
│  │  │  │  ├─ inventory/...
│  │  │  │  ├─ acquisitions/...
│  │  │  │  ├─ sales/...
│  │  │  │  └─ listings/...
│  │  │  ├─ components/
│  │  │  ├─ lib/                    # api client, auth helpers
│  │  │  ├─ hooks/
│  │  │  ├─ types/
│  │  │  └─ styles/
│  │  ├─ package.json
│  │  └─ next.config.ts
│  └─ docs-site/                    # optional future docs app
├─ packages/
│  ├─ api-contract/                 # optional shared DTO/Zod schema/types
│  └─ eslint-config/                # optional shared lint config
├─ database/
│  └─ schema.sql                    # existing source-of-truth schema
├─ docs/
│  ├─ er_diagram.md
│  ├─ snorlax_database_schema.md
│  └─ web_app_implementation_plan.md
├─ docker-compose.yml               # local postgres + api + web
├─ package.json                     # workspaces root
└─ pnpm-workspace.yaml              # if using pnpm
```

## 2) High-Level Delivery Plan

### Milestone A — Foundation and Infrastructure
- Bootstrap monorepo (`apps/api`, `apps/web`).
- Add NestJS app, Next.js app, and shared lint/format tooling.
- Configure local PostgreSQL via Docker.
- Configure environment management (`.env.example` for each app).

### Milestone B — Prisma and Database Integration
- Model Prisma schema from `database/schema.sql`.
- Keep SQL as canonical source and align Prisma mapping carefully.
- Add migrations strategy and seed script for lookups (`languages`, `card_conditions`, etc.).
- Add Prisma Studio and basic scripts for developer productivity.

### Milestone C — Backend API (NestJS)
- Implement modules aligned to schema domains:
  - Catalog
  - Inventory + ledger actions
  - Acquisitions/Sales
  - Marketplace listings
  - Reporting
- Add JWT auth and role-based guards.
- Add pagination/filter/sort conventions.
- Add OpenAPI docs and DTO validation.

### Milestone D — Frontend (Next.js)
- Build authenticated dashboard and domain pages.
- Implement reusable table/filter/form components.
- Integrate API with React Query and optimistic updates where safe.
- Build workflows for inventory movement, acquisitions, sales, and listings.

### Milestone E — Quality and Release
- Add unit + integration tests (API), component + smoke tests (web).
- Add CI checks: lint, typecheck, test, build.
- Add production docker builds and deployment runbook.
- Add monitoring/logging + health checks.

## 3) Detailed Domain-to-Module Mapping

Map existing schema objects into API modules for maintainability.

- **catalog**: `pokemon`, `eras`, `sets`, `card_types`, `card_prints`, `languages`, `card_print_languages`
- **inventory**: `inventory_items`, `inventory_movements`, `locations`, `card_conditions`
- **transactions**: `acquisitions`, `acquisition_lines`, `sales`, `sales_lines`
- **marketplaces**: `marketplaces`, `external_listings`, compatibility view adapters
- **reports**: endpoints over profitability and weighted cost views
- **auth/users**: `users` and permissions model

## 4) API Design Conventions

- Base path: `/api/v1`
- Pagination: `?page=1&pageSize=25`
- Sorting: `?sort=createdAt:desc`
- Filtering: explicit query params per resource (`setCode`, `language`, `condition`, etc.)
- Error shape: `{ code, message, details, requestId }`
- OpenAPI must be generated and versioned for frontend client alignment.

## 5) Initial Endpoint Backlog (MVP)

1. `POST /auth/login`, `POST /auth/refresh`, `POST /auth/logout`
2. `GET /catalog/card-prints`, `GET /catalog/card-prints/:id`
3. `POST /inventory/items`, `PATCH /inventory/items/:id`
4. `POST /inventory/movements` (append-only ledger write)
5. `POST /transactions/acquisitions`, `POST /transactions/sales`
6. `GET /marketplaces/listings`, `POST /marketplaces/listings`
7. `GET /reports/profitability/by-card`
8. `GET /reports/profitability/by-set`

## 6) Frontend Page Backlog (MVP)

1. Login page
2. Dashboard (inventory totals, value summaries, recent movements)
3. Card print explorer (search/filter + detail)
4. Inventory list + item detail/edit
5. Acquisition entry flow (header + lines)
6. Sales entry flow (header + lines)
7. Listings management page
8. Profitability reports pages

## 7) Two-Week Execution Checklist (Day-by-Day)

### Week 1
- **Day 1:** Create monorepo structure, workspace config, basic scripts.
- **Day 2:** Bootstrap NestJS and Next.js apps, wire shared lint/format.
- **Day 3:** Add PostgreSQL docker-compose, env templates, startup scripts.
- **Day 4:** Implement Prisma setup in API; map core catalog models.
- **Day 5:** Complete Prisma models for inventory + transactions + marketplaces.

### Week 2
- **Day 6:** Build auth module (JWT), guards, and user bootstrap flow.
- **Day 7:** Implement catalog APIs + OpenAPI docs.
- **Day 8:** Implement inventory APIs, including movement append-only rules.
- **Day 9:** Implement acquisitions/sales APIs and transactional writes.
- **Day 10:** Build core frontend screens (login, dashboard, catalog, inventory).
- **Day 11:** Build transactions/listings/report pages.
- **Day 12:** Add tests + CI + deployment scripts; run end-to-end smoke checks.

## 8) Critical Technical Decisions

- Keep `database/schema.sql` as source-of-truth and validate Prisma alignment in CI.
- Use database transactions for acquisitions/sales writes to preserve integrity.
- Preserve immutable ledger semantics in API layer for `inventory_movements`.
- Favor server-side pagination for all large lists.
- Use optimistic UI only where conflicts are low-risk.

## 9) Definition of Done (MVP)

- Authenticated users can:
  - browse catalog,
  - manage inventory,
  - record acquisitions and sales,
  - manage external listings,
  - view profitability reports.
- API and web pass lint/typecheck/tests.
- OpenAPI docs available and current.
- App can run locally with one command (`docker compose up` + workspace start script).
