-- =============================================================================
--  MIGRATION    : 012_add_schema_migrations_table.sql
--  DESCRIPTION  : Creates the bookkeeping table that records which migrations
--                 have been applied. Industry-standard migration runners
--                 (Flyway, sqitch, atlas, golang-migrate, ...) maintain a
--                 comparable table automatically; this hand-rolled version
--                 lets the project be wired up to those tools later with
--                 minimal effort.
-- =============================================================================
BEGIN;

CREATE TABLE IF NOT EXISTS schema_migrations (
    version      TEXT         PRIMARY KEY,
    description  TEXT,
    applied_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- Record every migration shipped with this repository so the table is
-- consistent with the on-disk migration set. Re-running is harmless thanks
-- to the ON CONFLICT clause.
INSERT INTO schema_migrations (version, description) VALUES
    ('001', 'create_films_table'),
    ('002', 'seed_initial_films'),
    ('003', 'add_metadata_columns'),
    ('004', 'backfill_metadata'),
    ('005', 'add_unique_film_name_constraint'),
    ('006', 'add_indexes'),
    ('007', 'add_check_constraints'),
    ('008', 'add_audit_timestamps'),
    ('009', 'promote_rating_to_enum'),
    ('010', 'normalize_genres'),
    ('011', 'add_fulltext_search'),
    ('012', 'add_schema_migrations_table')
ON CONFLICT (version) DO NOTHING;

COMMIT;
