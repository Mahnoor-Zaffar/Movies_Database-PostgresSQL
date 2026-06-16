# Performance Notes

This doc explains how to read query plans against the seeded `films` database
and demonstrates the impact of each index that ships with the schema.

> Sample output below was captured against `postgres:16-alpine` with the seed
> file loaded (5 rows). Numbers will look very different at scale; the goal of
> this document is to show how to *reason* about plans, not to publish
> microbenchmarks.

---

## Reading a plan in 30 seconds

```sql
EXPLAIN (ANALYZE, BUFFERS) <your query>;
```

- **`Seq Scan`** — Postgres read every page of the table. Fine for small
  tables and large result sets; a red flag on million-row tables.
- **`Index Scan` / `Index Only Scan`** — Postgres used an index. The smaller
  the `rows` estimate the planner produced, the more useful the index is.
- **`Bitmap Heap Scan`** — Used when many rows match. Postgres builds a bitmap
  from the index, sorts it, then fetches the heap pages in disk order.
- **`actual time=…`** is the truth; `cost=…` is the planner's estimate.
- **`Buffers: shared hit=… read=…`** — `hit` came from cache, `read` came
  from disk. Hot caches change the math dramatically.

---

## 1. Equality on `release_year` (uses `idx_films_release_year`)

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, name, release_year
FROM   films
WHERE  release_year = 1999;
```

On the seeded dataset Postgres is smart enough to seq-scan a 5-row table.
Force the index to see it in action:

```sql
SET enable_seqscan = OFF;
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, name, release_year
FROM   films
WHERE  release_year = 1999;
RESET enable_seqscan;
```

Expected plan (truncated):

```
 Index Scan using idx_films_release_year on films
   Index Cond: (release_year = 1999)
   Buffers: shared hit=2
```

At a few thousand rows or more, the planner will pick the index on its own.

## 2. Filtering by `rating` ENUM (uses `idx_films_rating`)

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, name
FROM   films
WHERE  rating = 'R';
```

ENUM comparisons are integer comparisons under the hood — far cheaper than
case-insensitive `LOWER(rating) = 'r'` lookups against a `VARCHAR`.

## 3. Full-text search (uses `idx_films_search_vector`, GIN)

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, name
FROM   films
WHERE  search_vector @@ websearch_to_tsquery('simple', 'matrix');
```

Expected plan:

```
 Bitmap Heap Scan on films
   Recheck Cond: (search_vector @@ '''matrix'''::tsquery)
   ->  Bitmap Index Scan on idx_films_search_vector
         Index Cond: (search_vector @@ '''matrix'''::tsquery)
```

`websearch_to_tsquery` understands quoted phrases (`"call me"`), OR
(`matrix or godfather`), and `-`negation — making it a safe entrypoint for
user-supplied search input.

## 4. Junction-table joins (uses `idx_film_genres_genre_id`)

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT f.name
FROM   films       f
JOIN   film_genres fg ON fg.film_id  = f.id
JOIN   genres      g  ON g.id        = fg.genre_id
WHERE  g.name = 'Action';
```

The `idx_film_genres_genre_id` index lets Postgres find every junction row
for the matching genre quickly, then nested-loop into `films` via the
implicit PK index.

## 5. UNIQUE constraint = free index

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id FROM films WHERE name = 'The Matrix';
```

```
 Index Scan using unique_film_name on films
```

PostgreSQL automatically creates a B-tree index to back any UNIQUE or
PRIMARY KEY constraint, so equality lookups on `name` are O(log n) without
any explicit `CREATE INDEX`.

---

## When to add (or remove) an index

| Symptom                                                       | Likely fix                              |
| ------------------------------------------------------------- | --------------------------------------- |
| `Seq Scan` on a large table for a selective predicate         | Add a B-tree index on the column        |
| `Seq Scan` despite an index existing                          | `ANALYZE`; predicate isn't selective    |
| Slow `LIKE 'foo%'` on small data                              | Add a `text_pattern_ops` B-tree         |
| Slow substring / `LIKE '%foo%'` / fuzzy search                | Use `pg_trgm` GIN or full-text search   |
| Write-heavy table with many unused indexes                    | Drop the indexes; profile with `pg_stat_user_indexes` |

## Useful catalog queries

```sql
-- Which indexes exist on films?
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'films';

-- How big are they?
SELECT relname AS index_name, pg_size_pretty(pg_relation_size(oid)) AS size
FROM   pg_class
WHERE  relkind = 'i'
ORDER  BY pg_relation_size(oid) DESC;

-- Are any unused?
SELECT s.indexrelname AS index_name, s.idx_scan AS scans
FROM   pg_stat_user_indexes s
WHERE  s.schemaname = 'public'
ORDER  BY s.idx_scan ASC;
```
