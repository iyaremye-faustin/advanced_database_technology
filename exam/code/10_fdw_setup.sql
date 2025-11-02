-- Task 10 (A2): Database Link via postgres_fdw (Node_A -> Node_B)

-- Here i used branch_a and branch_b 


CREATE EXTENSION IF NOT EXISTS postgres_fdw;

DROP SERVER IF EXISTS proj_link CASCADE;
CREATE SERVER proj_link
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (host '127.0.0.1', dbname 'branch_b', port '5432');

-- Map local role to remote role
DROP USER MAPPING IF EXISTS FOR CURRENT_USER SERVER proj_link;
CREATE USER MAPPING FOR CURRENT_USER
  SERVER proj_link
  OPTIONS (user 'postgres', password 'postgres');


IMPORT FOREIGN SCHEMA public
  LIMIT TO (hostel, room, payment, payment_mode, warden, students)
  FROM SERVER proj_link INTO public;


-- SELECT * FROM room LIMIT 5;
-- SELECT p.id, p.amount, s.first_name FROM payment p JOIN students s ON s.id=p.student_id LIMIT 5;
