-- =============================================================================
--  DOWN         : 006_add_indexes_down.sql
--  DESCRIPTION  : Drops the supporting B-tree indexes added by 006. The
--                 indexes backing PRIMARY KEY / UNIQUE constraints are NOT
--                 dropped here -- they belong to those constraints.
-- =============================================================================
BEGIN;

DROP INDEX IF EXISTS idx_films_release_year;
DROP INDEX IF EXISTS idx_films_category;

COMMIT;
