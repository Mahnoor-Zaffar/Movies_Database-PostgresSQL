-- =============================================================================
--  DOWN         : 005_add_unique_film_name_constraint_down.sql
--  DESCRIPTION  : Drops the retroactive UNIQUE constraint on films.name.
-- =============================================================================
BEGIN;

ALTER TABLE films DROP CONSTRAINT IF EXISTS unique_film_name;

COMMIT;
