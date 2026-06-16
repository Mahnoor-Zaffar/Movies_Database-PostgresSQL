-- =============================================================================
--  DOWN         : 011_add_fulltext_search_down.sql
--  DESCRIPTION  : Drops the full-text search column and its GIN index.
-- =============================================================================
BEGIN;

DROP INDEX  IF EXISTS idx_films_search_vector;
ALTER TABLE films DROP COLUMN IF EXISTS search_vector;

COMMIT;
