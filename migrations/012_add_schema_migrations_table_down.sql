-- =============================================================================
--  DOWN         : 012_add_schema_migrations_table_down.sql
--  DESCRIPTION  : Drops the schema_migrations tracking table.
-- =============================================================================
BEGIN;

DROP TABLE IF EXISTS schema_migrations;

COMMIT;
