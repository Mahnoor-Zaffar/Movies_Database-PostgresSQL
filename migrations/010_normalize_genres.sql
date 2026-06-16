-- =============================================================================
--  MIGRATION    : 010_normalize_genres.sql
--  DESCRIPTION  : Promotes the denormalized `films.category` column into a
--                 proper many-to-many relationship backed by `genres` and
--                 `film_genres`. The migration:
--                   1. Creates the new tables.
--                   2. Backfills genres from the distinct values of category.
--                   3. Creates film -> genre associations.
--                   4. Drops the obsolete category column.
--                 The supporting index on the junction table covers the
--                 reverse lookup (find all films for a given genre).
-- =============================================================================
BEGIN;

CREATE TABLE IF NOT EXISTS genres (
    id           SERIAL  PRIMARY KEY,
    name         TEXT    NOT NULL,
    description  TEXT,

    CONSTRAINT unique_genre_name UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS film_genres (
    film_id   INTEGER NOT NULL REFERENCES films  (id) ON DELETE CASCADE,
    genre_id  INTEGER NOT NULL REFERENCES genres (id) ON DELETE CASCADE,

    PRIMARY KEY (film_id, genre_id)
);

CREATE INDEX IF NOT EXISTS idx_film_genres_genre_id ON film_genres (genre_id);

-- Backfill from any pre-existing `category` values (no-op on fresh installs).
INSERT INTO genres (name)
    SELECT DISTINCT category
    FROM   films
    WHERE  category IS NOT NULL
    AND    NOT EXISTS (SELECT 1 FROM genres g WHERE g.name = films.category);

INSERT INTO film_genres (film_id, genre_id)
    SELECT f.id, g.id
    FROM   films  f
    JOIN   genres g ON g.name = f.category
    WHERE  f.category IS NOT NULL
    ON CONFLICT DO NOTHING;

ALTER TABLE films DROP COLUMN IF EXISTS category;

COMMIT;
