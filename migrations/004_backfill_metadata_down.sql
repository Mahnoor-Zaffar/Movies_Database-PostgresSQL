-- =============================================================================
--  DOWN         : 004_backfill_metadata_down.sql
--  DESCRIPTION  : Reverts the backfilled metadata to NULL for the seeded rows.
--                 (The columns themselves are dropped by 003_down.)
-- =============================================================================
BEGIN;

UPDATE films
SET    runtime    = NULL,
       category   = NULL,
       rating     = NULL,
       box_office = NULL
WHERE  name IN (
    'The Matrix',
    'Monsters Inc.',
    'Call Me By Your Name',
    'The Godfather',
    'Parasite'
);

COMMIT;
