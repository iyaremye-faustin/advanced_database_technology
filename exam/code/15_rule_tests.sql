-- Companion tests for B6 and B10 (failing and passing DML)
-- Failing #1: negative amount
BEGIN;
  INSERT INTO payment(payment_mode_id, amount, room_id, student_id, status, paid_at)
  VALUES (1, -10, 1, 1, 'paid', now());
ROLLBACK;

-- Failing #2: paid without timestamp
BEGIN;
  INSERT INTO payment(payment_mode_id, amount, room_id, student_id, status)
  VALUES (1, 10, 1, 1, 'paid');
ROLLBACK;

-- Passing #1
INSERT INTO payment(payment_mode_id, amount, room_id, student_id, status, paid_at)
VALUES (1, 10, 1, 1, 'paid', now());

-- Passing #2 (unpaid okay)
INSERT INTO payment(payment_mode_id, amount, room_id, student_id, status)
VALUES (1, 5, 1, 1, 'unpaid');
