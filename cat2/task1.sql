/* =======================================================
   HOSTEL MANAGEMENT - DISTRIBUTED DATABASE ASSIGNMENT
   PostgreSQL Implementation (Ubuntu / pgAdmin)
   ======================================================= */

------------------------------------------------------------
-- TASK 1: Distributed Schema Design & Fragmentation
------------------------------------------------------------
-- Create two databases manually in pgAdmin first:
--   branch_a  (Academics)
--   branch_b  (Operations)
-- Then connect to each DB separately to run its part.

-- ============ BRANCH_A ============ 

-- Connect to branch_a database before running the next section


BEGIN;

CREATE TYPE program_status AS ENUM ('active','closed');
CREATE TYPE gender AS ENUM ('male','female');
CREATE TYPE year_status AS ENUM ('active','closed');

CREATE TABLE program (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  status program_status NOT NULL DEFAULT 'active'
);

CREATE TABLE academic_year (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status year_status NOT NULL,
  CONSTRAINT chk_year_dates CHECK (end_date > start_date)
);

CREATE TABLE students (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(50) NOT NULL UNIQUE,
  telephone VARCHAR(50) NOT NULL,
  nationality VARCHAR(50) NOT NULL,
  date_of_birth DATE NOT NULL,
  gender gender NOT NULL,
  date_registered DATE DEFAULT CURRENT_DATE,
  program_id INT NOT NULL REFERENCES program(id)
);

CREATE TABLE registration (
  id SERIAL PRIMARY KEY,
  student_id INT NOT NULL REFERENCES students(id),
  registration_date DATE NOT NULL,
  academic_year_id INT NOT NULL REFERENCES academic_year(id),
  CONSTRAINT uq_registration UNIQUE (student_id, academic_year_id)
);

COMMIT;

-- Sample Data
INSERT INTO program (name) VALUES ('Computer Science'), ('Business Admin');
INSERT INTO academic_year (name, start_date, end_date, status)
VALUES ('2025/2026','2025-09-01','2026-07-31','active');
INSERT INTO students (first_name,last_name,email,telephone,nationality,date_of_birth,gender,program_id)
VALUES ('Alice','Niyonsaba','alice@example.com','+250780000001','Rwanda','2002-05-12','female',1),
       ('Eric','Hagenimana','eric@example.com','+250780000002','Rwanda','2001-11-03','male',2);
INSERT INTO registration (student_id,registration_date,academic_year_id)
VALUES (1,CURRENT_DATE,1),(2,CURRENT_DATE,1);


-- ============ BRANCH_B ============
-- Connect to branch_b before running the next section

BEGIN;

CREATE TYPE hostel_gender_type AS ENUM ('single','mixed');
CREATE TYPE room_status AS ENUM ('available','occupied');
CREATE TYPE warden_status AS ENUM ('active','inactive');
CREATE TYPE relation_status AS ENUM ('active','inactive');
CREATE TYPE payment_mode_status AS ENUM ('available','unavailable');
CREATE TYPE payment_status AS ENUM ('paid','unpaid');
CREATE TYPE maintenance_status AS ENUM ('pending','approved','completed','cancelled');
CREATE TYPE gender AS ENUM ('male','female');

CREATE TABLE hostel (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  capacity INT DEFAULT 1,
  gender_type hostel_gender_type NOT NULL
);

CREATE TABLE room (
  id SERIAL PRIMARY KEY,
  hostel_id INT NOT NULL REFERENCES hostel(id) ON DELETE CASCADE,
  room_number VARCHAR(50) NOT NULL,
  type VARCHAR(50) NOT NULL,
  status room_status DEFAULT 'available',
  CONSTRAINT uq_room UNIQUE (hostel_id, room_number)
);

CREATE TABLE warden (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  telephone VARCHAR(50) NOT NULL UNIQUE,
  gender gender NOT NULL,
  status warden_status DEFAULT 'active'
);

CREATE TABLE warden_hostels (
  id SERIAL PRIMARY KEY,
  hostel_id INT NOT NULL REFERENCES hostel(id),
  warden_id INT NOT NULL REFERENCES warden(id),
  shift_start_time TIME NOT NULL,
  shift_end_time TIME NOT NULL,
  status relation_status DEFAULT 'active'
);

CREATE TABLE payment_mode (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  status payment_mode_status DEFAULT 'available'
);

CREATE TABLE payment (
  id SERIAL PRIMARY KEY,
  payment_mode_id INT NOT NULL REFERENCES payment_mode(id),
  amount NUMERIC(12,2) DEFAULT 0,
  room_id INT NOT NULL REFERENCES room(id),
  student_id INT NOT NULL,
  status payment_status DEFAULT 'unpaid',
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE maintenance_request (
  id SERIAL PRIMARY KEY,
  room_id INT NOT NULL REFERENCES room(id) ON DELETE CASCADE,
  status maintenance_status DEFAULT 'pending',
  warden_id INT NOT NULL REFERENCES warden(id),
  issue TEXT NOT NULL,
  estimate_amount NUMERIC(12,2) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

COMMIT;

-- Insert Sample Data
INSERT INTO hostel (name,capacity,gender_type) VALUES ('Kigali A',200,'mixed'),('Kigali B',120,'single');
INSERT INTO room (hostel_id,room_number,type,status)
VALUES (1,'A-101','standard','available'),(1,'A-102','standard','available'),(2,'B-201','deluxe','occupied');
INSERT INTO warden (first_name,last_name,telephone,gender,status)
VALUES ('Paul','Mugisha','+250780000100','male','active'),('Diane','Uwase','+250780000101','female','active');
INSERT INTO warden_hostels (hostel_id,warden_id,shift_start_time,shift_end_time)
VALUES (1,1,'08:00','16:00'),(2,2,'09:00','17:00');
INSERT INTO payment_mode (name) VALUES ('Cash'),('Mobile Money'),('Card');
INSERT INTO payment (payment_mode_id,amount,room_id,student_id,status)
VALUES (2,50000,1,1,'paid'),(1,60000,3,2,'unpaid');