-- =============================================================================
--  MIGRATION    : 004_backfill_metadata.sql
--  DESCRIPTION  : Backfills the newly added metadata columns for every seeded
--                 row. Each UPDATE is narrowly scoped via a WHERE clause on
--                 the unique title to guarantee exactly one row is touched
--                 per statement. The batch runs in a single transaction so
--                 the backfill is all-or-nothing.
-- =============================================================================
BEGIN;

UPDATE films
SET    runtime    = 136,
       category   = 'Science Fiction',
       rating     = 'R',
       box_office = 467200000
WHERE  name = 'The Matrix';

UPDATE films
SET    runtime    = 92,
       category   = 'Animation',
       rating     = 'G',
       box_office = 579200000
WHERE  name = 'Monsters Inc.';

UPDATE films
SET    runtime    = 132,
       category   = 'Romance',
       rating     = 'R',
       box_office = 41100000
WHERE  name = 'Call Me By Your Name';

UPDATE films
SET    runtime    = 175,
       category   = 'Crime Drama',
       rating     = 'R',
       box_office = 250300000
WHERE  name = 'The Godfather';

UPDATE films
SET    runtime    = 132,
       category   = 'Thriller',
       rating     = 'R',
       box_office = 258800000
WHERE  name = 'Parasite';

COMMIT;
