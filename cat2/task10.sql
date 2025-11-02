------------------------------------------------------------
-- TASK 10: Performance Benchmark & Report
------------------------------------------------------------
-- 1) Centralized snapshot
DROP TABLE IF EXISTS _payment_snap;
CREATE TABLE _payment_snap AS SELECT * FROM payment;

EXPLAIN ANALYZE
SELECT COUNT(*), SUM(amount) FROM _payment_snap;

-- 2) Parallel
SET max_parallel_workers_per_gather = 4;
EXPLAIN ANALYZE
SELECT COUNT(*), SUM(amount) FROM _payment_snap;

-- 3) Distributed (FDW)
EXPLAIN ANALYZE
SELECT COUNT(*), SUM(amount) FROM payment;
