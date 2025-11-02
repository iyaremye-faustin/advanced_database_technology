-- Task 06: Prevent double allocation trigger

CREATE OR REPLACE FUNCTION prevent_double_allocation()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  v_cnt INT;
BEGIN
  IF (TG_OP='INSERT' AND NEW.status='paid')
     OR (TG_OP='UPDATE' AND NEW.status='paid' AND COALESCE(OLD.status,'unpaid') <> 'paid') THEN

    SELECT COUNT(*) INTO v_cnt
    FROM payment
    WHERE student_id = NEW.student_id AND status='paid' AND id <> COALESCE(NEW.id,-1);

    IF v_cnt > 0 THEN
      RAISE EXCEPTION 'Student % already has a paid allocation', NEW.student_id;
    END IF;

    UPDATE room SET status='occupied', updated_at=now() WHERE id=NEW.room_id;
  END IF;
  RETURN NEW;
END$$;

CREATE TRIGGER trg_prevent_double_allocation
BEFORE INSERT OR UPDATE ON payment
FOR EACH ROW EXECUTE FUNCTION prevent_double_allocation();
