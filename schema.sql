-- =============================================================================
--  FILE         : schema.sql
--  PROJECT      : Movie Database (PostgreSQL Blueprint)
--  PURPOSE      : Authoritative consolidated DDL describing the FINAL state of
--                 the database. Run this on a fresh database to reproduce the
--                 schema without replaying the migration history.
--  TARGET DB    : PostgreSQL 12+ (CI uses 16-alpine)
--  USAGE        : psql -U <user> -d <database> -f schema.sql
-- =============================================================================


-- -----------------------------------------------------------------------------
-- DEFENSIVE RESET
-- -----------------------------------------------------------------------------
-- Drops every object owned by this script so it can be replayed from a clean
-- slate. Comment these out in production deployments where data must persist.
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS film_genres        CASCADE;
DROP TABLE IF EXISTS genres             CASCADE;
DROP TABLE IF EXISTS films              CASCADE;
DROP TABLE IF EXISTS schema_migrations  CASCADE;
DROP TYPE  IF EXISTS film_rating        CASCADE;
DROP FUNCTION IF EXISTS set_updated_at();


-- -----------------------------------------------------------------------------
-- ENUM TYPE : film_rating
-- -----------------------------------------------------------------------------
-- Domain-constrained set of allowed content ratings. Using an ENUM rather than
-- a free-form VARCHAR prevents typos ('r' vs 'R') and shrinks the on-disk
-- representation to 4 bytes per row.
-- -----------------------------------------------------------------------------
CREATE TYPE film_rating AS ENUM ('G', 'PG', 'PG-13', 'R', 'NC-17', 'NR');


-- -----------------------------------------------------------------------------
-- FUNCTION : set_updated_at()
-- -----------------------------------------------------------------------------
-- Trigger function attached to every audited table. Refreshes `updated_at` on
-- every UPDATE so callers can never forget to bump it.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- -----------------------------------------------------------------------------
-- TABLE : films
-- -----------------------------------------------------------------------------
-- Core catalog. `name` is unique. CHECK constraints reject obviously bogus
-- values up front. `search_vector` powers full-text search via a GIN index.
-- -----------------------------------------------------------------------------
CREATE TABLE films (
    id              SERIAL          PRIMARY KEY,
    name            TEXT            NOT NULL,
    release_year    INTEGER         NOT NULL,
    runtime         INTEGER,
    rating          film_rating,
    box_office      BIGINT,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    search_vector   TSVECTOR        GENERATED ALWAYS AS (to_tsvector('simple', name)) STORED,

    CONSTRAINT unique_film_name       UNIQUE  (name),
    CONSTRAINT chk_release_year_sane  CHECK   (release_year BETWEEN 1888 AND 2100),
    CONSTRAINT chk_runtime_positive   CHECK   (runtime IS NULL OR runtime > 0),
    CONSTRAINT chk_box_office_nonneg  CHECK   (box_office IS NULL OR box_office >= 0)
);

CREATE TRIGGER trg_films_set_updated_at
    BEFORE UPDATE ON films
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();


-- -----------------------------------------------------------------------------
-- TABLE : genres
-- -----------------------------------------------------------------------------
-- Lookup table for normalized genre labels. Names are unique so a single
-- canonical row backs every association.
-- -----------------------------------------------------------------------------
CREATE TABLE genres (
    id           SERIAL  PRIMARY KEY,
    name         TEXT    NOT NULL,
    description  TEXT,

    CONSTRAINT unique_genre_name UNIQUE (name)
);


-- -----------------------------------------------------------------------------
-- TABLE : film_genres (junction)
-- -----------------------------------------------------------------------------
-- Many-to-many association between films and genres. Composite PK guarantees
-- a film can carry a given genre at most once. ON DELETE CASCADE keeps the
-- junction tidy when either side is deleted.
-- -----------------------------------------------------------------------------
CREATE TABLE film_genres (
    film_id   INTEGER NOT NULL REFERENCES films  (id) ON DELETE CASCADE,
    genre_id  INTEGER NOT NULL REFERENCES genres (id) ON DELETE CASCADE,

    PRIMARY KEY (film_id, genre_id)
);


-- -----------------------------------------------------------------------------
-- TABLE : schema_migrations
-- -----------------------------------------------------------------------------
-- Records which numbered migration files have been applied. A real migration
-- runner (Flyway, sqitch, atlas, golang-migrate, ...) would maintain this
-- table automatically; the structure here mirrors the conventions of those
-- tools so the project can be wired up to them with minimal effort.
-- -----------------------------------------------------------------------------
CREATE TABLE schema_migrations (
    version      TEXT         PRIMARY KEY,
    description  TEXT,
    applied_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);


-- -----------------------------------------------------------------------------
-- INDEXES
-- -----------------------------------------------------------------------------
-- PRIMARY KEY and UNIQUE constraints already create their own B-tree indexes;
-- only secondary indexes need to be declared here.
-- -----------------------------------------------------------------------------
CREATE INDEX idx_films_release_year   ON films       (release_year);
CREATE INDEX idx_films_rating         ON films       (rating);
CREATE INDEX idx_films_search_vector  ON films USING GIN (search_vector);
CREATE INDEX idx_film_genres_genre_id ON film_genres (genre_id);


-- -----------------------------------------------------------------------------
-- METADATA COMMENTS (visible in psql `\d+` and most GUI clients)
-- -----------------------------------------------------------------------------
COMMENT ON TABLE  films                 IS 'Catalog of films tracked by the system.';
COMMENT ON COLUMN films.id              IS 'Surrogate primary key (auto-incremented).';
COMMENT ON COLUMN films.name            IS 'Film title; unique across the table.';
COMMENT ON COLUMN films.release_year    IS 'Year of the film''s public release (1888-2100).';
COMMENT ON COLUMN films.runtime         IS 'Runtime of the film in whole minutes (>0 when set).';
COMMENT ON COLUMN films.rating          IS 'Content rating; constrained to the film_rating ENUM.';
COMMENT ON COLUMN films.box_office      IS 'Worldwide lifetime gross revenue (USD), >=0 when set.';
COMMENT ON COLUMN films.created_at      IS 'Row creation timestamp.';
COMMENT ON COLUMN films.updated_at      IS 'Last-modification timestamp; refreshed by trigger.';
COMMENT ON COLUMN films.search_vector   IS 'Generated tsvector over name; indexed for full-text search.';

COMMENT ON TABLE  genres                IS 'Normalized lookup of genre labels.';
COMMENT ON TABLE  film_genres           IS 'Many-to-many association between films and genres.';
COMMENT ON TABLE  schema_migrations     IS 'Audit log of applied database migrations.';
