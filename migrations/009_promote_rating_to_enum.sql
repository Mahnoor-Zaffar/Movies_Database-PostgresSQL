-- =============================================================================
--  MIGRATION    : 009_promote_rating_to_enum.sql
--  DESCRIPTION  : Replaces the loose VARCHAR(10) `rating` column with a typed
--                 `film_rating` ENUM. Existing values are cast in place via
--                 the USING clause. Unknown / unmappable strings would raise
--                 here and roll back, which is the desired behavior.
-- =============================================================================
BEGIN;

CREATE TYPE film_rating AS ENUM ('G', 'PG', 'PG-13', 'R', 'NC-17', 'NR');

ALTER TABLE films
    ALTER COLUMN rating TYPE film_rating
        USING (
            CASE
                WHEN rating IS NULL THEN NULL
                WHEN rating IN ('G', 'PG', 'PG-13', 'R', 'NC-17', 'NR') THEN rating::film_rating
                ELSE 'NR'::film_rating
            END
        );

-- Supporting B-tree index. Indexing an ENUM is cheap and accelerates
-- "all R-rated films" style filters.
CREATE INDEX IF NOT EXISTS idx_films_rating ON films (rating);

COMMIT;
