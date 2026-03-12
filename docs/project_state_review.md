<!-- SPDX-License-Identifier: CC-BY-NC-4.0 -->
# Project State Review (Documentation vs. Implementation)

## Review scope
This review compares the current repository implementation against:
- `README.md`
- `docs/web_app_implementation_plan.md`
- `docs/snorlax_database_schema.md`
- API/Web source scaffolding under `apps/api` and `apps/web`

It also records current quality-gate command outcomes (`lint`, `typecheck`, `build`).

## Executive summary
Overall, the project is in a **solid scaffold / early-delivery phase**:
- The **database modeling intent** is well documented and largely represented in Prisma and API domain modules.
- The **MVP API endpoint backlog listed in docs is implemented at the route level**.
- The **web app remains mostly page scaffolds**, consistent with a foundation milestone but not yet close to product-complete behavior.
- The **main readiness gap is quality tooling**: linting currently fails due to missing ESLint flat config for ESLint v9.

## What aligns well

### 1) Repo structure alignment with implementation plan
The monorepo structure recommended in `docs/web_app_implementation_plan.md` is present:
- `apps/api` and `apps/web` exist and build.
- `packages/api-contract` and `packages/eslint-config` placeholders exist.
- Root scripts and workspace configuration are in place.

### 2) API route coverage vs. MVP backlog
The implementation plan's initial endpoint backlog is reflected in controllers:
- Auth login/refresh/logout
- Catalog list/detail for card prints
- Inventory create/update items + movement write
- Transactions acquisitions/sales
- Marketplace list/create listings
- Reports profitability by card/by set

This is a strong milestone signal: route-level API skeleton is materially complete for the documented MVP backlog.

### 3) Schema-centric domain fidelity
The schema docs emphasize normalized references, immutable movement ledger behavior, and reporting views. Current code aligns by:
- Maintaining domain modules matching schema areas (catalog, inventory, transactions, marketplaces, reports).
- Querying reporting views directly for profitability endpoints.
- Modeling core entities/enums in Prisma with table/column mappings.

## Key gaps and risks

### 1) Lint pipeline is broken (highest-priority engineering gap)
`pnpm -r lint` currently fails in `apps/api` because ESLint v9 expects `eslint.config.*`, while no flat config exists.

**Impact:**
- CI quality gate cannot be trusted/enforced.
- Style and static-code issues can regress unnoticed.

**Recommendation (P0):**
- Add a root/shared ESLint flat config and wire `apps/api` + `apps/web` to it.
- Re-run lint in CI and ensure fail/pass behavior is deterministic.

### 2) Web app remains scaffold-level, not feature-level
Current Next.js pages are placeholder content with static headings and minimal routing links.

**Impact:**
- Product workflows (auth flow, data views, CRUD forms, filtering) are not yet implemented.
- End-user value remains limited despite backend scaffold progress.

**Recommendation (P1):**
- Implement vertical slices per page (e.g., Dashboard metrics read-only first, then Catalog browse with filters).
- Introduce shared UI components + API client layer before deeper feature work.

### 3) Auth is token-based but still minimal
Auth service issues and verifies HMAC tokens, but current flow is intentionally lightweight.

**Observed constraints:**
- No visible password credential verification path.
- Logout is currently stateless success response.
- Role/permission guard system from plan is not yet present.

**Recommendation (P1):**
- Add explicit authentication model milestones in docs (current vs. target),
  then incrementally deliver credential verification + authorization guards.

### 4) Documentation maturity exceeds implementation maturity
`docs/web_app_implementation_plan.md` describes a production-ready trajectory (tests, CI, monitoring, OpenAPI), while current codebase is still mostly foundational scaffolding.

**Impact:**
- New contributors may overestimate readiness.

**Recommendation (P2):**
- Add a concise "Current delivery status" table in README (Foundation / In Progress / Not Started by milestone).

## Quality-check evidence snapshot
- `pnpm install`: pass (workspace up-to-date).
- `pnpm -r lint`: fail due to ESLint v9 config mismatch.
- `pnpm -r typecheck`: pass for API and web.
- `pnpm -r build`: pass for API and web production builds.

## Prioritized action plan
1. **P0:** Restore linting with ESLint v9 flat config and CI enforcement.
2. **P1:** Deliver first functional web vertical slice (dashboard + catalog read paths).
3. **P1:** Harden auth roadmap (credential handling, authorization guards, session/token policy).
4. **P2:** Add explicit implementation-status matrix to README.
5. **P2:** Add minimal automated tests (API smoke + web route smoke) to align with plan's quality milestone.

## Staff-level approval assessment
Would a staff engineer approve the current state?
- **For foundation progress:** Yes — architecture direction and MVP route scaffolding are coherent.
- **For release readiness:** No — lint gate is broken, UI is mostly scaffold, and quality/reliability layers are incomplete.

Overall assessment: **Good foundational trajectory, not release-ready yet.**
