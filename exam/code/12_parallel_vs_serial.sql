-- Task 12 (A3): Serial vs Parallel aggregation using Postgres

-- SERIAL-ish (discourage parallel)
SET max_parallel_workers_per_gather = 0;

SELECT h.id AS hostel_id,
       h.name AS hostel_name,
       date_trunc('month', p.paid_at)::date AS month_start,
       SUM(p.amount) AS total_paid
FROM payment p
JOIN room r ON r.id=p.room_id
JOIN hostel h ON h.id=r.hostel_id
WHERE p.status='paid'
GROUP BY h.id, h.name, date_trunc('month', p.paid_at)
ORDER BY hostel_id, month_start;

-- PARALLEL-encouraged
SET max_parallel_workers_per_gather = 4;
SELECT h.id AS hostel_id,
       h.name AS hostel_name,
       date_trunc('month', p.paid_at)::date AS month_start,
       SUM(p.amount) AS total_paid
FROM payment p
JOIN room r ON r.id=p.room_id
JOIN hostel h ON h.id=r.hostel_id
WHERE p.status='paid'
GROUP BY h.id, h.name, date_trunc('month', p.paid_at)
ORDER BY hostel_id, month_start;


-- EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT ... (run the two queries above)
