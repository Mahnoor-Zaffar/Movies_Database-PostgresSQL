-- =============================================================================
--  MIGRATION    : 006_add_indexes.sql
--  DESCRIPTION  : Adds supporting B-tree indexes on the most frequently
--                 filtered columns. PostgreSQL already indexes PRIMARY KEY
--                 (`id`) and UNIQUE columns (`name`) automatically, so no
--                 explicit index is needed for those.
-- =============================================================================
BEGIN;

CREATE INDEX IF NOT EXISTS idx_films_release_year ON films (release_year);
CREATE INDEX IF NOT EXISTS idx_films_category     ON films (category);

COMMIT;
