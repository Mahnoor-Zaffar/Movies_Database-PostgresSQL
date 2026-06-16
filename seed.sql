-- =============================================================================
--  FILE         : seed.sql
--  PROJECT      : Movie Database (PostgreSQL Blueprint)
--  PURPOSE      : Populate the `films` table with a small, public-domain set
--                 of well-known titles for local testing and CI fixtures.
--                 Box-office figures are approximate worldwide lifetime gross
--                 in USD; data is non-sensitive and safe to commit.
--  PREREQ       : schema.sql must have been executed first.
--  USAGE        : psql -U <user> -d <database> -f seed.sql
-- =============================================================================

BEGIN;

-- Wipe any prior seed run so this script is idempotent.
TRUNCATE TABLE films RESTART IDENTITY CASCADE;

INSERT INTO films
    (name,                   release_year, runtime, category,          rating, box_office)
VALUES
    ('The Matrix',                   1999,     136, 'Science Fiction', 'R',     467200000),
    ('Monsters Inc.',                2001,      92, 'Animation',       'G',     579200000),
    ('Call Me By Your Name',         2017,     132, 'Romance',         'R',      41100000),
    ('The Godfather',                1972,     175, 'Crime Drama',     'R',     250300000),
    ('Parasite',                     2019,     132, 'Thriller',        'R',     258800000);

COMMIT;
