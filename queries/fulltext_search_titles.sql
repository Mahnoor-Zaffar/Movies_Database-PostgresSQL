-- =============================================================================
--  QUERY        : fulltext_search_titles.sql
--  DESCRIPTION  : Demonstrates the GIN-indexed `search_vector` column added by
--                 migration 011. `websearch_to_tsquery` understands Google-
--                 style operators (quoted phrases, OR, -negation), making it
--                 the recommended entrypoint for user-supplied search input.
-- =============================================================================

SELECT
    id,
    name,
    release_year,
    ts_rank(search_vector, websearch_to_tsquery('simple', 'matrix')) AS rank
FROM
    films
WHERE
    search_vector @@ websearch_to_tsquery('simple', 'matrix')
ORDER BY
    rank DESC;
