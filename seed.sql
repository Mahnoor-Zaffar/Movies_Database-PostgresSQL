-- =============================================================================
--  FILE         : seed.sql
--  PROJECT      : Movie Database (PostgreSQL Blueprint)
--  PURPOSE      : Populate the catalog with a small public-domain dataset for
--                 local testing and CI fixtures. All data is non-sensitive and
--                 safe to commit; box-office figures are approximate worldwide
--                 lifetime gross in USD.
--  PREREQ       : schema.sql must have been executed first.
--  USAGE        : psql -U <user> -d <database> -f seed.sql
-- =============================================================================

BEGIN;

-- Re-seedable: wipe any prior run. Order matters because of FK constraints.
TRUNCATE TABLE film_genres, films, genres RESTART IDENTITY CASCADE;

-- -----------------------------------------------------------------------------
-- 1. Genres
-- -----------------------------------------------------------------------------
INSERT INTO genres (name, description) VALUES
    ('Science Fiction', 'Speculative, technology-driven storytelling.'),
    ('Animation',       'Frame-by-frame or computer-generated imagery.'),
    ('Romance',         'Stories centered on emotional relationships.'),
    ('Crime Drama',     'Drama focused on criminal acts and consequences.'),
    ('Thriller',        'Suspense-driven narratives with high tension.'),
    ('Action',          'Physical feats, combat, chases, and stunts.'),
    ('Comedy',          'Humor-driven storytelling.');

-- -----------------------------------------------------------------------------
-- 2. Films
-- -----------------------------------------------------------------------------
INSERT INTO films
    (name,                   release_year, runtime, rating,  box_office)
VALUES
    ('The Matrix',                   1999,     136, 'R',      467200000),
    ('Monsters Inc.',                2001,      92, 'G',      579200000),
    ('Call Me By Your Name',         2017,     132, 'R',       41100000),
    ('The Godfather',                1972,     175, 'R',      250300000),
    ('Parasite',                     2019,     132, 'R',      258800000);

-- -----------------------------------------------------------------------------
-- 3. Film <-> Genre associations
-- -----------------------------------------------------------------------------
-- Subselects avoid hard-coding surrogate IDs; the join is resolved by the
-- natural keys (`films.name`, `genres.name`) which the schema enforces as
-- UNIQUE so the lookup is deterministic.
-- -----------------------------------------------------------------------------
INSERT INTO film_genres (film_id, genre_id)
SELECT f.id, g.id FROM films f, genres g WHERE (f.name, g.name) IN (
    ('The Matrix',           'Science Fiction'),
    ('The Matrix',           'Action'),
    ('Monsters Inc.',        'Animation'),
    ('Monsters Inc.',        'Comedy'),
    ('Call Me By Your Name', 'Romance'),
    ('The Godfather',        'Crime Drama'),
    ('Parasite',             'Thriller')
);

COMMIT;
