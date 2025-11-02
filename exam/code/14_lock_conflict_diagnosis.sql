-- Task 14 (A5): Distributed lock conflict & diagnosis
-- Open two sessions to reproduce
-- Session 1 (Node_A):
-- BEGIN;
-- UPDATE payment SET amount = amount + 1 WHERE id = 1;

-- Session 2 (from Node_B or another session on Node_A):
-- BEGIN;
-- UPDATE payment SET amount = amount + 1 WHERE id = 1;  -- will block

-- Diagnose locks from a third session on Node_A:
SELECT now() AS ts, l.locktype, l.mode, l.granted, a.pid, a.usename, a.query
FROM pg_locks l
JOIN pg_stat_activity a ON a.pid = l.pid
ORDER BY a.pid;

-- After observing, release Session 1:
-- COMMIT; -- Session 1
-- Then Session 2 completes:
-- COMMIT; -- Session 2
