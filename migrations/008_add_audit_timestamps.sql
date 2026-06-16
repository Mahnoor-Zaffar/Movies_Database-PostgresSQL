-- =============================================================================
--  MIGRATION    : 008_add_audit_timestamps.sql
--  DESCRIPTION  : Adds `created_at` and `updated_at` audit columns to `films`
--                 plus a trigger function that refreshes `updated_at` on
--                 every UPDATE. TIMESTAMPTZ is used so values are stored in
--                 UTC and presented in the client's session timezone.
-- =============================================================================
BEGIN;

ALTER TABLE films
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_films_set_updated_at ON films;

CREATE TRIGGER trg_films_set_updated_at
    BEFORE UPDATE ON films
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

COMMIT;
