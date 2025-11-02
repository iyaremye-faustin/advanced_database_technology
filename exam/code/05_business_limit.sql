-- Task 05: Business Limit Trigger

DROP TABLE IF EXISTS business_limits CASCADE;
CREATE TABLE business_limits(
  rule_key VARCHAR(64) PRIMARY KEY,
  threshold INTEGER NOT NULL CHECK (threshold > 0),
  active CHAR(1) NOT NULL CHECK (active IN ('Y','N'))
);

INSERT INTO business_limits(rule_key, threshold, active)
VALUES ('MAX_PAID_PER_ROOM', 1, 'Y')
ON CONFLICT (rule_key) DO UPDATE SET threshold=EXCLUDED.threshold, active=EXCLUDED.active;

CREATE OR REPLACE FUNCTION fn_should_alert_max_paid_per_room(p_room_id INT, p_new_status TEXT)
RETURNS BOOLEAN LANGUAGE plpgsql AS $$
DECLARE
  v_active CHAR(1);
  v_thr INT;
  v_cnt INT;
BEGIN
  SELECT active, threshold INTO v_active, v_thr FROM business_limits WHERE rule_key='MAX_PAID_PER_ROOM';
  IF v_active <> 'Y' THEN RETURN FALSE; END IF;
  IF p_new_status <> 'paid' THEN RETURN FALSE; END IF;
  SELECT COUNT(*) INTO v_cnt FROM payment WHERE room_id=p_room_id AND status='paid';
  RETURN (v_cnt + 1) > v_thr;
END$$;

CREATE OR REPLACE FUNCTION trg_business_limit_guard()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='INSERT' THEN
    IF fn_should_alert_max_paid_per_room(NEW.room_id, NEW.status) THEN
      RAISE EXCEPTION 'Business limit exceeded for room %', NEW.room_id;
    END IF;
  ELSIF TG_OP='UPDATE' THEN
    IF fn_should_alert_max_paid_per_room(NEW.room_id, NEW.status) THEN
      RAISE EXCEPTION 'Business limit exceeded for room %', NEW.room_id;
    END IF;
  END IF;
  RETURN NEW;
END$$;

CREATE TRIGGER trg_business_limit_guard
BEFORE INSERT OR UPDATE ON payment
FOR EACH ROW EXECUTE FUNCTION trg_business_limit_guard();
