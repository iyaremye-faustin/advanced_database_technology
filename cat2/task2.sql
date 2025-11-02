------------------------------------------------------------
-- TASK 2: Create and Use Database Links (Foreign Data Wrapper)
------------------------------------------------------------
-- Run in branch_a

CREATE EXTENSION IF NOT EXISTS postgres_fdw;
CREATE SERVER branch_b_srv
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (host '127.0.0.1', dbname 'branch_b', port '5432');

CREATE USER MAPPING FOR app_user SERVER branch_b_srv OPTIONS (user 'app_user', password 'changeme');


-- Populate the types if not already existing
CREATE TYPE hostel_gender_type AS ENUM ('single','mixed');
CREATE TYPE room_status AS ENUM ('available','occupied');
CREATE TYPE warden_status AS ENUM ('active','inactive');
CREATE TYPE relation_status AS ENUM ('active','inactive');
CREATE TYPE payment_mode_status AS ENUM ('available','unavailable');
CREATE TYPE payment_status AS ENUM ('paid','unpaid');
CREATE TYPE maintenance_status AS ENUM ('pending','approved','completed','cancelled');


IMPORT FOREIGN SCHEMA public
  LIMIT TO (hostel, room, payment, payment_mode, warden)
  FROM SERVER branch_b_srv INTO public;


-- Verify that the link works by querying a foreign table (this is just an example and it is optional)
SELECT COUNT(*) FROM room;
SELECT s.first_name, s.last_name, SUM(p.amount) AS total_paid
FROM students s
JOIN payment p ON p.student_id = s.id
GROUP BY s.first_name, s.last_name;