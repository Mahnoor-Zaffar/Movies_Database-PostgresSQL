-- =============================================================================
--  DOWN         : 002_seed_initial_films_down.sql
--  DESCRIPTION  : Removes the seeded rows. RESTART IDENTITY resets the SERIAL
--                 sequence so subsequent inserts start from 1 again.
-- =============================================================================
BEGIN;

TRUNCATE TABLE films RESTART IDENTITY CASCADE;

COMMIT;
