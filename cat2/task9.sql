
------------------------------------------------------------
-- TASK 9: Distributed Query Optimization
------------------------------------------------------------
ALTER SERVER branch_b_srv OPTIONS (ADD use_remote_estimate 'true');  

EXPLAIN (ANALYZE, VERBOSE)
SELECT s.first_name, s.last_name, SUM(p.amount) AS total_paid
FROM students s
JOIN payment p ON p.student_id = s.id
GROUP BY s.first_name, s.last_name;