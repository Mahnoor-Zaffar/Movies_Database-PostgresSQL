-- =============================================================================
--  DOWN         : 007_add_check_constraints_down.sql
--  DESCRIPTION  : Drops the CHECK constraints added by 007.
-- =============================================================================
BEGIN;

ALTER TABLE films
    DROP CONSTRAINT IF EXISTS chk_release_year_sane,
    DROP CONSTRAINT IF EXISTS chk_runtime_positive,
    DROP CONSTRAINT IF EXISTS chk_box_office_nonneg;

COMMIT;
