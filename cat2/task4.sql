------------------------------------------------------------
-- TASK 4: Two-Phase Commit Simulation
------------------------------------------------------------
-- Enable prepared transactions (once as postgres superuser):
-- ALTER SYSTEM SET max_prepared_transactions = 50; SELECT pg_reload_conf();

-- branch_a
BEGIN;
INSERT INTO registration (student_id,registration_date,academic_year_id)
VALUES (1,CURRENT_DATE,1);
PREPARE TRANSACTION 'tx_demo';

-- branch_b
BEGIN;
INSERT INTO payment (payment_mode_id,amount,room_id,student_id,status)
VALUES (1,20000,1,1,'paid');
PREPARE TRANSACTION 'tx_demo'; 

-- Then commit both:
COMMIT PREPARED 'tx_demo';  -- Run in both databases
