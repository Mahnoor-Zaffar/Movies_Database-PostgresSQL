-- =============================================================================
--  DOWN         : 010_normalize_genres_down.sql
--  DESCRIPTION  : Restores the denormalized `films.category` column by
--                 collapsing each film's first associated genre back into
--                 a scalar value, then drops the junction and lookup tables.
--                 NOTE: this is lossy for films with multiple genres.
-- =============================================================================
BEGIN;

ALTER TABLE films ADD COLUMN IF NOT EXISTS category VARCHAR(100);

UPDATE films f
SET    category = sub.genre_name
FROM   (
    SELECT DISTINCT ON (fg.film_id)
           fg.film_id,
           g.name AS genre_name
    FROM   film_genres fg
    JOIN   genres      g ON g.id = fg.genre_id
    ORDER  BY fg.film_id, g.name
) AS sub
WHERE  f.id = sub.film_id;

DROP TABLE IF EXISTS film_genres CASCADE;
DROP TABLE IF EXISTS genres      CASCADE;

COMMIT;
