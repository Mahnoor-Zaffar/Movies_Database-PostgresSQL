-- =============================================================================
--  QUERY        : filter_by_release_year.sql
--  DESCRIPTION  : Returns every film released in a specific calendar year.
--                 In production this is the shape of query an application's
--                 data-access layer would issue with a $1 placeholder; the
--                 literal 1999 is hard-coded here for script-driven demos.
-- =============================================================================

SELECT
    id,
    name,
    release_year,
    runtime,
    category,
    rating,
    box_office
FROM
    films
WHERE
    release_year = 1999
ORDER BY
    name ASC;
