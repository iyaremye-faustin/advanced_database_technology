-- Task 04: Payment audit triggers

DROP TABLE IF EXISTS payment_audit CASCADE;
CREATE TABLE payment_audit (
  id BIGSERIAL PRIMARY KEY,
  bef_total NUMERIC(14,2),
  aft_total NUMERIC(14,2),
  changed_at TIMESTAMP DEFAULT now(),
  reason TEXT NOT NULL
);

DROP TABLE IF EXISTS payment_audit_ctx;
CREATE TABLE payment_audit_ctx(id INT PRIMARY KEY DEFAULT 1, bef_total NUMERIC(14,2));
INSERT INTO payment_audit_ctx(id, bef_total) VALUES (1,0) ON CONFLICT DO NOTHING;

CREATE OR REPLACE FUNCTION f_payment_audit_before()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  UPDATE payment_audit_ctx
  SET bef_total = COALESCE((SELECT SUM(amount) FROM payment WHERE status='paid'),0);
  RETURN NULL;
END$$;

CREATE OR REPLACE FUNCTION f_payment_audit_after()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  v_bef NUMERIC(14,2);
  v_aft NUMERIC(14,2);
BEGIN
  SELECT bef_total INTO v_bef FROM payment_audit_ctx WHERE id=1;
  SELECT COALESCE(SUM(amount),0) INTO v_aft FROM payment WHERE status='paid';
  INSERT INTO payment_audit(bef_total, aft_total, reason) VALUES (v_bef, v_aft, TG_OP);
  RETURN NULL;
END$$;

CREATE TRIGGER trg_payment_audit_before
BEFORE INSERT OR UPDATE OR DELETE ON payment
FOR EACH STATEMENT EXECUTE FUNCTION f_payment_audit_before();

CREATE TRIGGER trg_payment_audit_after
AFTER INSERT OR UPDATE OR DELETE ON payment
FOR EACH STATEMENT EXECUTE FUNCTION f_payment_audit_after();
