# Product Requirement Document (PRD): Movie Database CLI/GUI Project

## 1. Executive Summary & Strategy
* **Positioning:** A foundational PostgreSQL educational database designed to demonstrate mastery over essential DDL, DML, and table constraints using CLI queries and GUI database clients (e.g., Postbird, DBeaver, pgAdmin).
* **Core Objective:** Build a clean, scalable relational model for film tracking that prevents data duplication and provides foundational data analysis capabilities.
* **ROI / Value Metrics:** Eliminates dirty data through constraint implementation, reduces query execution overhead by mapping explicit data types (`BIGINT`, `INTEGER`), and establishes a blueprint for schema migrations.

---

## 2. Technical Features & Requirements

### 2.1 Table Schema Architecture (`films`)
The system maintains a core `films` table with the following structural layout:

| Column Name    | Data Type        | Constraints                | Purpose                                       |
| :------------- | :--------------- | :------------------------- | :-------------------------------------------- |
| `id`           | `SERIAL`         | `PRIMARY KEY`, `NOT NULL`  | Unique row identifier (auto-incremented)      |
| `name`         | `TEXT`           | `UNIQUE`, `NOT NULL`       | The title of the movie                        |
| `release_year` | `INTEGER`        | `NOT NULL`, `CHECK`        | The year the movie was released               |
| `runtime`      | `INTEGER`        | `CHECK > 0`                | Duration of the movie in minutes              |
| `rating`       | `film_rating`    | ENUM domain                | Content rating (G / PG / PG-13 / R / NC-17 / NR) |
| `box_office`   | `BIGINT`         | `CHECK >= 0`               | Total lifetime earnings in USD                |
| `created_at`   | `TIMESTAMPTZ`    | `DEFAULT NOW()`            | Insert timestamp                              |
| `updated_at`   | `TIMESTAMPTZ`    | `DEFAULT NOW()`, trigger   | Last-modification timestamp                   |
| `search_vector`| `tsvector`       | GIN-indexed                | Full-text search index over `name`            |

Supporting relations:

| Table          | Purpose                                                            |
| :------------- | :----------------------------------------------------------------- |
| `genres`       | Lookup table of normalized genre labels                            |
| `film_genres`  | Many-to-many junction between `films` and `genres`                 |
| `schema_migrations` | Tracks which numbered migrations have been applied            |

### 2.2 System Operations & Milestones
* **Phase 1: Table Initialization** — Structural foundation via raw SQL scripts.
* **Phase 2: Seed Population** — Initial core assets (*The Matrix*, *Monsters Inc.*, *Call Me By Your Name*) plus filler titles.
* **Phase 3: Schema Migrations (ALTER)** — Dynamic columns to capture deeper metadata post-population.
* **Phase 4: Backfill Processes** — Data normalization via analytical batch updates for `NULL` fields.
* **Phase 5: Integrity Engineering** — Retroactive binding of data logic constraints (`UNIQUE`, `CHECK`, `FK`).
* **Phase 6: Performance Engineering** — B-tree and GIN indexes; `EXPLAIN ANALYZE` benchmarks.
* **Phase 7: Auditability** — `created_at` / `updated_at` columns with trigger-driven mutation tracking.

---

## 3. Scope & Out of Scope
* **In Scope:** Raw SQL scripts for definition, mutation, and optimization; integration workflows with database clients; Dockerized local environment; CI verification.
* **Out of Scope:** Application backend layers (Node.js/Python connectors), frontend UI creation, live IMDb API ingestion sync routines.
