
------------------------------------------------------------
-- TASK 7: Parallel Data Loading / ETL Simulation
------------------------------------------------------------
CREATE TABLE payment_src AS
SELECT g AS student_id,
       1 AS payment_mode_id,
       (random()*9000 + 1000)::int AS amount,
       1 AS room_id,
       'paid'::payment_status AS status,
       NOW() - (g || ' minutes')::interval AS created_at
FROM generate_series(1,500000) g;

ANALYZE payment_src;

SET max_parallel_workers_per_gather = 4;
EXPLAIN ANALYZE
INSERT INTO payment (payment_mode_id,amount,room_id,student_id,status,created_at)
SELECT payment_mode_id,amount,room_id,student_id,status,created_at FROM payment_src;