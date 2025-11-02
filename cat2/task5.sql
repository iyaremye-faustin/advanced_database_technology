
------------------------------------------------------------
-- TASK 5: Distributed Rollback & Recovery
------------------------------------------------------------
-- Create a stuck transaction (prepare but don't commit)
BEGIN;
INSERT INTO payment (payment_mode_id,amount,room_id,student_id,status)
VALUES (1,30000,1,1,'paid');
PREPARE TRANSACTION 'tx_stuck';

-- Check prepared transactions
SELECT * FROM pg_prepared_xacts;

-- Roll back
ROLLBACK PREPARED 'tx_stuck';