-- =============================================================================
--  MIGRATION    : 002_seed_initial_films.sql
--  DESCRIPTION  : Populates the canonical seed rows required by the project
--                 brief plus two filler titles drawn from diverse release
--                 years. A single multi-row VALUES clause is used to keep
--                 the insert within a single WAL boundary.
-- =============================================================================
BEGIN;

INSERT INTO films (name, release_year) VALUES
    ('The Matrix',           1999),
    ('Monsters Inc.',        2001),
    ('Call Me By Your Name', 2017),
    ('The Godfather',        1972),
    ('Parasite',             2019);

COMMIT;
