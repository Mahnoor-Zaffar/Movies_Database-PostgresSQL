-- =============================================================================
--  QUERY        : test_unique_constraint.sql
--  DESCRIPTION  : Integrity resilience test for the `unique_film_name`
--                 constraint. Run in a sandbox / disposable database to
--                 verify the schema rejects duplicate titles atomically.
--
--  EXPECTED     : 1. First INSERT (a brand new title) succeeds.
--                 2. Second INSERT collides with 'The Matrix' and raises:
--                        ERROR:  duplicate key value violates unique
--                                constraint "unique_film_name"
--                        DETAIL: Key (name)=(The Matrix) already exists.
--                        SQLSTATE: 23505
--                 3. ROLLBACK reverses the first INSERT; table is unchanged.
-- =============================================================================

BEGIN;

    -- Step 1: a benign insert that would normally succeed.
    INSERT INTO films (name, release_year)
    VALUES ('Inception', 2010);

    -- Step 2: an intentional collision with an existing seeded title.
    --         This statement MUST raise a unique_violation (SQLSTATE 23505).
    INSERT INTO films (name, release_year)
    VALUES ('The Matrix', 2099);

ROLLBACK;  -- Swap to COMMIT in a throwaway DB to observe the txn abort.
