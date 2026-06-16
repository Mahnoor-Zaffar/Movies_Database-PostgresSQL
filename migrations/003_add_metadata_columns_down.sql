-- =============================================================================
--  DOWN         : 003_add_metadata_columns_down.sql
--  DESCRIPTION  : Drops the metadata columns introduced in 003.
-- =============================================================================
BEGIN;

ALTER TABLE films
    DROP COLUMN IF EXISTS runtime,
    DROP COLUMN IF EXISTS category,
    DROP COLUMN IF EXISTS rating,
    DROP COLUMN IF EXISTS box_office;

COMMIT;
