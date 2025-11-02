------------------------------------------------------------
-- TASK 3: Parallel Query Execution
------------------------------------------------------------
SET max_parallel_workers_per_gather = 0;
EXPLAIN ANALYZE SELECT COUNT(*) FROM payment;

SET max_parallel_workers_per_gather = 4;
EXPLAIN ANALYZE SELECT COUNT(*) FROM payment;


-- The above query can result in no effect because parallelism will be applied to a foreign table / table accessed remotely.

--- Try also this and compare the output of the querr running in local server---

SET max_parallel_workers_per_gather = 0;
EXPLAIN ANALYZE SELECT COUNT(*) FROM students;

SET max_parallel_workers_per_gather = 4;
EXPLAIN ANALYZE SELECT COUNT(*) FROM students;

