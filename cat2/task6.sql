------------------------------------------------------------
-- TASK 6: Distributed Concurrency Control
------------------------------------------------------------
-- Open 2 pgAdmin tabs:
-- Tab 1:
BEGIN;
UPDATE room SET status='occupied' WHERE id=1;

-- Tab 2:
BEGIN;
UPDATE room SET status='available' WHERE id=1; -- blocks

-- Tab 3 (monitor):
SELECT pid, query, state FROM pg_stat_activity WHERE state<>'idle';
SELECT locktype, mode, granted, pid FROM pg_locks WHERE NOT granted;
