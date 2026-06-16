-- =============================================================================
--  MIGRATION    : 005_add_unique_film_name_constraint.sql
--  DESCRIPTION  : Retroactively binds a UNIQUE constraint to `films.name`.
--                 The constraint is given an explicit, human-readable name
--                 (`unique_film_name`) so it can be referenced or dropped by
--                 name in future migrations.
--
--                 PostgreSQL validates the constraint against existing rows
--                 at creation time; if duplicates exist the statement fails
--                 and the transaction rolls back, preserving prior state.
-- =============================================================================
BEGIN;

ALTER TABLE films
    ADD CONSTRAINT unique_film_name UNIQUE (name);

COMMIT;
