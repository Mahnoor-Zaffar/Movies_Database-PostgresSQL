-- =============================================================================
--  DOWN         : 008_add_audit_timestamps_down.sql
--  DESCRIPTION  : Removes the audit columns and the supporting trigger.
-- =============================================================================
BEGIN;

DROP TRIGGER  IF EXISTS trg_films_set_updated_at ON films;
DROP FUNCTION IF EXISTS set_updated_at();

ALTER TABLE films
    DROP COLUMN IF EXISTS created_at,
    DROP COLUMN IF EXISTS updated_at;

COMMIT;
