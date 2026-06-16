-- =============================================================================
--  QUERY        : aggregate_box_office_by_category.sql
--  DESCRIPTION  : Rolls up worldwide box office and average runtime by genre.
--                 After migration 010 the category lives in the normalized
--                 `genres` table, so this query JOINs through the junction.
--                 Demonstrates: JOIN, GROUP BY, aggregate functions, NULLS
--                 ordering.
-- =============================================================================

SELECT
    g.name                AS genre,
    COUNT(*)              AS title_count,
    SUM(f.box_office)     AS total_box_office_usd,
    ROUND(AVG(f.runtime)) AS avg_runtime_minutes
FROM
    films             AS f
INNER JOIN
    film_genres       AS fg ON fg.film_id  = f.id
INNER JOIN
    genres            AS g  ON g.id        = fg.genre_id
GROUP BY
    g.name
ORDER BY
    total_box_office_usd DESC NULLS LAST;
