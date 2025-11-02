-- Task 13 (A4): Two-Phase Commit (2PC) style demo
-- Postgres supports prepared transactions with PREPARE TRANSACTION / COMMIT PREPARED.
-- This script shows a logical 2PC flow. To truly demonstrate cross-DB 2PC,
-- run a coordinated script on Node_A and a companion on Node_B.

-- Enable prepared transactions in postgresql.conf:
--   max_prepared_transactions = 50
-- Then reload/restart the server.

-- 1) Start local transaction on Node_A
BEGIN;
  INSERT INTO payment(payment_mode_id, amount, room_id, student_id, status, paid_at)
  VALUES (1, 50.00, 1, 1, 'paid', now());
PREPARE TRANSACTION 'txA1';

-- 2) On Node_B (REMOTE): run a similar block and PREPARE TRANSACTION 'txB1';
--    For demo, you can simulate on same DB with a different savepoint name.
--    BEGIN; ... PREPARE TRANSACTION 'txB1';

-- 3) Coordinator phase: if both prepared OK, commit both:
-- COMMIT PREPARED 'txA1';
-- -- on Node_B:
-- COMMIT PREPARED 'txB1';

-- 4) Failure/Recovery: if one side failed, ROLLBACK PREPARED on the other:
-- ROLLBACK PREPARED 'txA1';

-- Inspect prepared transactions:
-- SELECT * FROM pg_prepared_xacts;
