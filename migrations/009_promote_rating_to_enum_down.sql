-- =============================================================================
--  DOWN         : 009_promote_rating_to_enum_down.sql
--  DESCRIPTION  : Reverts `rating` to VARCHAR(10) and drops the ENUM type.
-- =============================================================================
BEGIN;

DROP INDEX IF EXISTS idx_films_rating;

ALTER TABLE films
    ALTER COLUMN rating TYPE VARCHAR(10) USING rating::text;

DROP TYPE IF EXISTS film_rating;

COMMIT;
