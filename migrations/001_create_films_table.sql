-- =============================================================================
--  MIGRATION    : 001_create_films_table.sql
--  AUTHOR       : Senior Database Engineer
--  DESCRIPTION  : Initial table creation. Establishes the minimum viable
--                 schema with auto-incrementing primary key plus the two
--                 mandatory columns required for v1 of the catalog.
-- =============================================================================
BEGIN;

CREATE TABLE IF NOT EXISTS films (
    id              SERIAL      PRIMARY KEY,
    name            TEXT        NOT NULL,
    release_year    INTEGER     NOT NULL
);

COMMIT;
