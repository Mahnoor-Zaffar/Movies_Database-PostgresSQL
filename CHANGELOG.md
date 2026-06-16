# Changelog

All notable changes to this project are documented in this file. The format
is loosely based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and the project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Each entry maps 1:1 to a numbered migration file under `migrations/`.

## [Unreleased]

## [0.2.0] — 2026-06-16

### Added
- `migrations/007_add_check_constraints.sql` — CHECK guards on `release_year`,
  `runtime`, and `box_office`.
- `migrations/008_add_audit_timestamps.sql` — `created_at` and `updated_at`
  columns plus a trigger function (`set_updated_at()`) that touches
  `updated_at` on every UPDATE.
- `migrations/009_promote_rating_to_enum.sql` — Replaces `VARCHAR(10)` rating
  with a typed `film_rating` ENUM.
- `migrations/010_normalize_genres.sql` — Introduces `genres` and
  `film_genres` tables, backfills associations from the old `category`
  column, then drops `films.category`.
- `migrations/011_add_fulltext_search.sql` — Adds a `search_vector` tsvector
  column with a GIN index for full-text search over titles.
- `migrations/012_add_schema_migrations_table.sql` — Tracking table that
  records every applied migration.
- Down-migrations (`*_down.sql`) for every numbered migration.
- `tests/test_schema_assertions.sql` — In-database assertions verifying
  schema invariants and seed-data counts.
- `.github/workflows/ci.yml` — GitHub Actions pipeline that boots Postgres,
  applies the migrations, loads seed data, and runs the assertions.
- `docs/PERFORMANCE.md` — `EXPLAIN ANALYZE` walkthroughs of indexed vs.
  un-indexed query plans.
- `docs/er-diagram.svg` — Lightweight vector ER diagram (replaces the
  oversized PNG).
- `Makefile` — Common developer commands (`make up`, `make psql`,
  `make seed`, `make test`, `make lint`).
- `.sqlfluff` — Lint configuration enforcing a consistent SQL style.
- `LICENSE` — MIT license file.
- `adminer` sidecar in `docker-compose.yml` for browser-based inspection
  on `http://localhost:8080`.

### Changed
- `schema.sql` now reflects the fully evolved schema including the genre
  relations, ENUM type, audit columns, and tsvector index.
- `seed.sql` seeds the normalized genres + film_genres relationship and
  uses the new ENUM values.
- `queries/aggregate_box_office_by_category.sql` rewritten to JOIN through
  the normalized genres tables.
- README updated with CI / license / Postgres badges, expanded setup
  instructions, and references to the new docs and tests.

### Removed
- `docs/er-diagram.png` (1.1 MB) — replaced by `docs/er-diagram.svg`.

## [0.1.0] — 2026-06-16

### Added
- Initial schema (`migrations/001_create_films_table.sql`) and seed data
  (`migrations/002_seed_initial_films.sql`).
- Metadata columns migration (`003_add_metadata_columns.sql`) and backfill
  (`004_backfill_metadata.sql`).
- Retroactive `unique_film_name` constraint (`005_add_unique_film_name_constraint.sql`).
- Supporting indexes (`006_add_indexes.sql`).
- `schema.sql`, `seed.sql`, `docker-compose.yml`, `.env.example`,
  `.gitignore`, `README.md`, sample queries, and the original PNG ER diagram.
