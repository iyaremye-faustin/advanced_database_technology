-- Task 02: Add constraints to enforce data integrity in payment and room table

ALTER TABLE payment
  ADD CONSTRAINT chk_payment_amount_positive CHECK (amount > 0),
  ADD CONSTRAINT chk_payment_paid_has_timestamp CHECK (
    (status = 'paid' AND paid_at IS NOT NULL) OR (status = 'unpaid')
  );

ALTER TABLE room
  ADD CONSTRAINT chk_room_type_nonempty CHECK (length(trim(type)) > 0);
