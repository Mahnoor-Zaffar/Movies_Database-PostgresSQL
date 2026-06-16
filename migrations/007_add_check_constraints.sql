-- =============================================================================
--  MIGRATION    : 007_add_check_constraints.sql
--  DESCRIPTION  : Hardens data quality by rejecting obviously bogus values for
--                 the numeric columns. CHECK predicates must be IMMUTABLE, so
--                 a hard upper bound (2100) is used for `release_year` rather
--                 than EXTRACT(YEAR FROM CURRENT_DATE).
-- =============================================================================
BEGIN;

ALTER TABLE films
    ADD CONSTRAINT chk_release_year_sane  CHECK (release_year BETWEEN 1888 AND 2100),
    ADD CONSTRAINT chk_runtime_positive   CHECK (runtime IS NULL OR runtime > 0),
    ADD CONSTRAINT chk_box_office_nonneg  CHECK (box_office IS NULL OR box_office >= 0);

COMMIT;
