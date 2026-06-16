-- =============================================================================
--  DOWN         : 001_create_films_table_down.sql
--  DESCRIPTION  : Drops the initial `films` table. CASCADE removes dependent
--                 objects (FKs, views) so the rollback is total.
-- =============================================================================
BEGIN;

DROP TABLE IF EXISTS films CASCADE;

COMMIT;
