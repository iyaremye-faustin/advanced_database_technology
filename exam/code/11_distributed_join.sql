-- Task 11 (A2 continued): Cross-node join staying within 3–10 rows
-- Assumes foreign tables were imported by 10_fdw_setup.sql

-- (1) Show remote sample rows (cap to 5)
-- SELECT * FROM room LIMIT 5;

-- (2) Distributed join: local payment (or payment_a/all) with remote students
-- Ensure result rows = 3–10 by filtering
SELECT p.id AS pay_id,
       p.amount,
       p.status,
       s.first_name,
       s.last_name
FROM payment p
JOIN students s ON s.id = p.student_id
WHERE p.status IN ('paid','unpaid')
FETCH FIRST 10 ROWS ONLY; 
