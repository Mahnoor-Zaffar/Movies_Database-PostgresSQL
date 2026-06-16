-- =============================================================================
--  QUERY        : aggregate_box_office_by_category.sql
--  DESCRIPTION  : Rolls up total worldwide box office and average runtime by
--                 category. Demonstrates GROUP BY, aggregate functions, and
--                 NULLS-aware ordering.
-- =============================================================================

SELECT
    category,
    COUNT(*)             AS title_count,
    SUM(box_office)      AS total_box_office_usd,
    ROUND(AVG(runtime))  AS avg_runtime_minutes
FROM
    films
WHERE
    category IS NOT NULL
GROUP BY
    category
ORDER BY
    total_box_office_usd DESC NULLS LAST;
