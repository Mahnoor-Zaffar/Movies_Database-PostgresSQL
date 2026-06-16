-- =============================================================================
--  FILE         : tests/test_schema_assertions.sql
--  PURPOSE      : In-database smoke tests that verify the schema's invariants
--                 and the integrity of the seed data. Wired into CI by
--                 `.github/workflows/ci.yml` and runnable locally via
--                 `make test`.
--
--                 Every check uses ASSERT, so the script exits non-zero (and
--                 raises) the moment any expectation is violated. Run with
--                 `psql -v ON_ERROR_STOP=1 -f tests/test_schema_assertions.sql`
--                 to surface failures cleanly to CI.
-- =============================================================================

\echo '== running schema + data assertions =='

-- ---------------------------------------------------------------------------
-- TEST 01: every expected table exists.
-- ---------------------------------------------------------------------------
DO $$
BEGIN
    ASSERT (
        SELECT COUNT(*) FROM information_schema.tables
        WHERE  table_schema = 'public'
        AND    table_name IN ('films', 'genres', 'film_genres', 'schema_migrations')
    ) = 4, 'expected the four core tables to exist';
END $$;

-- ---------------------------------------------------------------------------
-- TEST 02: the film_rating ENUM exists and contains the canonical values.
-- ---------------------------------------------------------------------------
DO $$
BEGIN
    ASSERT EXISTS (
        SELECT 1 FROM pg_type WHERE typname = 'film_rating'
    ), 'film_rating ENUM must exist';

    ASSERT (
        SELECT COUNT(*) FROM pg_enum e
        JOIN   pg_type t ON t.oid = e.enumtypid
        WHERE  t.typname = 'film_rating'
    ) = 6, 'film_rating ENUM must have 6 values (G, PG, PG-13, R, NC-17, NR)';
END $$;

-- ---------------------------------------------------------------------------
-- TEST 03: seed data was loaded.
-- ---------------------------------------------------------------------------
DO $$
DECLARE
    films_count       integer;
    genres_count      integer;
    associations      integer;
BEGIN
    SELECT COUNT(*) INTO films_count  FROM films;
    SELECT COUNT(*) INTO genres_count FROM genres;
    SELECT COUNT(*) INTO associations FROM film_genres;

    ASSERT films_count  = 5, format('expected 5 films, got %s',  films_count);
    ASSERT genres_count = 7, format('expected 7 genres, got %s', genres_count);
    ASSERT associations >= 5, format('expected at least 5 film_genres rows, got %s', associations);
END $$;

-- ---------------------------------------------------------------------------
-- TEST 04: the unique constraint rejects duplicates.
-- ---------------------------------------------------------------------------
DO $$
DECLARE
    sqlstate_caught text;
BEGIN
    BEGIN
        INSERT INTO films (name, release_year) VALUES ('The Matrix', 2099);
        RAISE EXCEPTION 'duplicate insert was NOT rejected';
    EXCEPTION WHEN unique_violation THEN
        sqlstate_caught := SQLSTATE;
    END;

    ASSERT sqlstate_caught = '23505',
        format('expected SQLSTATE 23505, got %s', sqlstate_caught);
END $$;

-- ---------------------------------------------------------------------------
-- TEST 05: CHECK constraints reject obviously bogus values.
-- ---------------------------------------------------------------------------
DO $$
DECLARE
    caught text;
BEGIN
    BEGIN
        INSERT INTO films (name, release_year) VALUES ('Time Traveler', 3000);
        RAISE EXCEPTION 'release_year CHECK constraint did NOT fire';
    EXCEPTION WHEN check_violation THEN
        caught := SQLSTATE;
    END;
    ASSERT caught = '23514', 'expected CHECK violation 23514 for release_year';

    caught := NULL;
    BEGIN
        INSERT INTO films (name, release_year, runtime)
        VALUES ('Negative Runtime', 2020, -10);
        RAISE EXCEPTION 'runtime CHECK constraint did NOT fire';
    EXCEPTION WHEN check_violation THEN
        caught := SQLSTATE;
    END;
    ASSERT caught = '23514', 'expected CHECK violation 23514 for runtime';

    caught := NULL;
    BEGIN
        INSERT INTO films (name, release_year, box_office)
        VALUES ('Negative Gross', 2020, -1);
        RAISE EXCEPTION 'box_office CHECK constraint did NOT fire';
    EXCEPTION WHEN check_violation THEN
        caught := SQLSTATE;
    END;
    ASSERT caught = '23514', 'expected CHECK violation 23514 for box_office';
END $$;

-- ---------------------------------------------------------------------------
-- TEST 06: the updated_at trigger refreshes the timestamp on UPDATE.
-- ---------------------------------------------------------------------------
DO $$
DECLARE
    before_ts timestamptz;
    after_ts  timestamptz;
BEGIN
    SELECT updated_at INTO before_ts FROM films WHERE name = 'The Matrix';

    -- Ensure clock advances even on very fast runners.
    PERFORM pg_sleep(0.05);

    UPDATE films SET runtime = runtime WHERE name = 'The Matrix';

    SELECT updated_at INTO after_ts FROM films WHERE name = 'The Matrix';

    ASSERT after_ts > before_ts,
        format('updated_at should advance on UPDATE (before=%s, after=%s)', before_ts, after_ts);
END $$;

-- ---------------------------------------------------------------------------
-- TEST 07: full-text search returns the expected row.
-- ---------------------------------------------------------------------------
DO $$
DECLARE
    hit_count integer;
BEGIN
    SELECT COUNT(*) INTO hit_count
    FROM   films
    WHERE  search_vector @@ websearch_to_tsquery('simple', 'matrix');

    ASSERT hit_count = 1, format('expected exactly 1 FTS hit for "matrix", got %s', hit_count);
END $$;

-- ---------------------------------------------------------------------------
-- TEST 08: schema_migrations records every numbered migration shipped.
-- ---------------------------------------------------------------------------
DO $$
BEGIN
    ASSERT (SELECT COUNT(*) FROM schema_migrations) >= 12,
        'schema_migrations must reflect every migration applied';
END $$;

\echo '== all assertions passed =='
