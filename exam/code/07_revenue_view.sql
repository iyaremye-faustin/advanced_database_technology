-- Task 07: Hostel monthly revenue view

CREATE OR REPLACE VIEW hostel_revenue_monthly AS
SELECT h.id AS hostel_id,
       h.name AS hostel_name,
       date_trunc('month', p.paid_at)::date AS month_start,
       SUM(p.amount) AS total_paid
FROM payment p
JOIN room r ON r.id = p.room_id
JOIN hostel h ON h.id = r.hostel_id
WHERE p.status='paid'
GROUP BY h.id, h.name, date_trunc('month', p.paid_at);
