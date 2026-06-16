-- =============================================================================
--  MIGRATION    : 011_add_fulltext_search.sql
--  DESCRIPTION  : Adds a generated `search_vector` tsvector column over the
--                 film title and a supporting GIN index. The GENERATED ALWAYS
--                 clause keeps the column in lockstep with `name` without a
--                 trigger.
--
--  QUERY EXAMPLE:
--      SELECT id, name
--      FROM   films
--      WHERE  search_vector @@ websearch_to_tsquery('simple', 'matrix');
-- =============================================================================
BEGIN;

ALTER TABLE films
    ADD COLUMN IF NOT EXISTS search_vector TSVECTOR
        GENERATED ALWAYS AS (to_tsvector('simple', name)) STORED;

CREATE INDEX IF NOT EXISTS idx_films_search_vector ON films USING GIN (search_vector);

COMMIT;
