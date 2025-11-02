/* =====================================================================
   ANSWERS TO TASKS
   ===================================================================== */

-- 1) Ensure/Apply CASCADE DELETE between Room → Maintenance
-- (Already defined in table creation: fk_mr_room ON DELETE CASCADE)

-- Drop and reapply the constraint with CASCADE
ALTER TABLE maintenance_request
  DROP CONSTRAINT IF EXISTS fk_mr_room;
ALTER TABLE maintenance_request
  ADD CONSTRAINT fk_mr_room
  FOREIGN KEY (room_id) REFERENCES room(id)
  ON UPDATE CASCADE ON DELETE CASCADE;


-- 2) Insert 3 hostels and 10 students (plus minimal supporting data)

-- Insert a program (required by students during creating accounts)
INSERT INTO program (name, status) VALUES
('Computer Science', 'active')
ON CONFLICT (name) DO NOTHING;

-- Insert optional academic years)
INSERT INTO academic_year (name, start_date, end_date, status) VALUES
('AY 2025', '2025-01-01', '2025-12-31', 'active')
ON CONFLICT (name) DO NOTHING;

-- Insert 3 hostels
INSERT INTO hostel (name, capacity, gender_type) VALUES
('Gikondo branch', 120, 'mixed'),
('Nyarugenge branch', 80, 'single'),
('Remera branch', 60, 'mixed')
ON CONFLICT (name) DO NOTHING;

-- A few rooms to support some relationship 
INSERT INTO room (hostel_id, room_number, type, status) VALUES
(1, 'A-101', 'double', 'available'),
(1, 'A-102', 'single', 'available'),
(2, 'B-201', 'double', 'available'),
(2, 'B-202', 'single', 'available'),
(3, 'C-301', 'double', 'available')
ON CONFLICT DO NOTHING;

-- Insert 10 students in students table
INSERT INTO students
(first_name, last_name, email, telephone, nationality, date_of_birth, gender, date_registered, program_id)
VALUES
('Alice','Uwizeye','alice1@example.com','+250780000001','Rwandan','2002-01-10','female','2025-01-10',1),
('Bob','Hakizimana','bob2@example.com','+250780000002','Rwandan','2001-02-12','male','2025-01-10',1),
('Celine','Mukamana','celine3@example.com','+250780000003','Rwandan','2003-03-05','female','2025-01-10',1),
('David','Mugisha','david4@example.com','+250780000004','Rwandan','2000-04-22','male','2025-01-10',1),
('Emma','Iradukunda','emma5@example.com','+250780000005','Rwandan','2002-05-02','female','2025-01-10',1),
('Frank','Nsengiyumva','frank6@example.com','+250780000006','Rwandan','2001-06-18','male','2025-01-10',1),
('Grace','Uwera','grace7@example.com','+250780000007','Rwandan','2002-07-07','female','2025-01-10',1),
('Henry','Ndayisenga','henry8@example.com','+250780000008','Rwandan','2000-08-28','male','2025-01-10',1),
('Irene','Uwambajimana','irene9@example.com','+250780000009','Rwandan','2003-09-14','female','2025-01-10',1),
('Jack','Mutabazi','jack10@example.com','+250780000010','Rwandan','2001-10-30','male','2025-01-10',1)
ON CONFLICT (email) DO NOTHING;

-- Insert payment modes support revenue details
INSERT INTO payment_mode (name, status) VALUES
('Cash', 'available'),
('Mobile Money', 'available'),
('Card', 'available')
ON CONFLICT (name) DO NOTHING;


-- 3) Retrieve list of occupied rooms with payment status

WITH last_payment AS (
  SELECT DISTINCT ON (p.room_id)
         p.room_id, p.status AS payment_status, p.amount, p.paid_at, p.student_id
  FROM payment p
  ORDER BY p.room_id, COALESCE(p.paid_at, NOW()) DESC, p.id DESC
)
SELECT
  r.id AS room_id,
  r.room_number,
  h.name AS hostel_name,
  lp.payment_status,
  lp.amount,
  lp.paid_at,
  s.first_name || ' ' || s.last_name AS last_paying_student
FROM room r
JOIN hostel h ON h.id = r.hostel_id
LEFT JOIN last_payment lp ON lp.room_id = r.id
LEFT JOIN students s ON s.id = lp.student_id
WHERE r.status = 'occupied'
ORDER BY h.name, r.room_number;


-- 4) Update room status after student checkout
CREATE OR REPLACE FUNCTION mark_room_occupied_on_payment()
RETURNS TRIGGER AS $$
BEGIN
  -- If the new payment is confirmed (status = 'paid'), mark the room occupied
  IF NEW.status = 'paid' THEN
    UPDATE room
      SET status = 'occupied'
    WHERE id = NEW.room_id;

  -- Otherwise, if payment reverted or unpaid, free the room
  ELSIF NEW.status = 'unpaid' THEN
    UPDATE room
      SET status = 'available'
    WHERE id = NEW.room_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on insert or update of payment
DROP TRIGGER IF EXISTS trg_mark_room_occupied_on_payment ON payment;
CREATE TRIGGER trg_mark_room_occupied_on_payment
AFTER INSERT OR UPDATE ON payment
FOR EACH ROW
EXECUTE FUNCTION mark_room_occupied_on_payment();

-- 5) Identify rooms with repeated maintenance issues


SELECT
  r.id AS room_id,
  r.room_number,
  h.name AS hostel_name,
  COUNT(*) AS request_count
FROM maintenance_request mr
JOIN room r   ON r.id = mr.room_id
JOIN hostel h ON h.id = r.hostel_id
GROUP BY r.id, r.room_number, h.name
HAVING COUNT(*) > 1
ORDER BY request_count DESC, hostel_name, room_number;



-- 6) View summarizing hostel revenue per month (paid payments only)
CREATE OR REPLACE VIEW hostel_revenue_monthly AS
SELECT
  date_trunc('month', p.paid_at)::date AS month,
  h.id    AS hostel_id,
  h.name  AS hostel_name,
  SUM(p.amount)        AS total_revenue,
  COUNT(*)             AS total_payments
FROM payment p
JOIN room r   ON r.id = p.room_id
JOIN hostel h ON h.id = r.hostel_id
WHERE p.status = 'paid' AND p.paid_at IS NOT NULL
GROUP BY 1, h.id, h.name;

-- Example:
-- SELECT * FROM hostel_revenue_monthly ORDER BY month, hostel_name;


-- 7) Trigger to prevent double allocation of the same room (via payment inserts)
CREATE OR REPLACE FUNCTION prevent_double_allocation()
RETURNS TRIGGER AS $$
DECLARE
  v_status TEXT;
BEGIN
  SELECT status INTO v_status FROM room WHERE id = NEW.room_id FOR UPDATE;
  IF v_status IS NULL THEN
    RAISE EXCEPTION 'Room % does not exist', NEW.room_id;
  END IF;

  IF v_status <> 'available' THEN
    RAISE EXCEPTION 'Room % is currently %, cannot allocate again',
      NEW.room_id, v_status;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prevent_double_allocation ON payment;
CREATE TRIGGER trg_prevent_double_allocation
BEFORE INSERT ON payment
FOR EACH ROW
EXECUTE FUNCTION prevent_double_allocation();

