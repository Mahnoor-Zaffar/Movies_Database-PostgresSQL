-- =============================================================================
--  MIGRATION    : 003_add_metadata_columns.sql
--  DESCRIPTION  : Extends the `films` table with four additional nullable
--                 metadata columns. Each ALTER TABLE is issued separately
--                 for readability and so any single failure can be isolated.
--                 `box_office` uses BIGINT because top-grossing films exceed
--                 the ~2.147B ceiling of a 32-bit INTEGER.
-- =============================================================================
BEGIN;

ALTER TABLE films ADD COLUMN IF NOT EXISTS runtime    INTEGER;
ALTER TABLE films ADD COLUMN IF NOT EXISTS category   VARCHAR(100);
ALTER TABLE films ADD COLUMN IF NOT EXISTS rating     VARCHAR(10);
ALTER TABLE films ADD COLUMN IF NOT EXISTS box_office BIGINT;

COMMIT;
