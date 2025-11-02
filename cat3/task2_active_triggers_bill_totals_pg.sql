
-- =========================================
-- Task 2 (PostgreSQL): Active DB (E-C-A) - Bill Totals That Stay Correct
-- =========================================
SET client_min_messages = WARNING;

DROP TABLE IF EXISTS bill_audit CASCADE;
DROP TABLE IF EXISTS bill_item CASCADE;
DROP TABLE IF EXISTS bill CASCADE;

CREATE TABLE bill (
  id    INTEGER PRIMARY KEY,
  total NUMERIC(12,2) DEFAULT 0
);

CREATE TABLE bill_item (
  bill_id    INTEGER NOT NULL REFERENCES bill(id) ON DELETE CASCADE,
  amount     NUMERIC(12,2) NOT NULL,
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE bill_audit (
  bill_id    INTEGER NOT NULL,
  old_total  NUMERIC(12,2),
  new_total  NUMERIC(12,2),
  changed_at TIMESTAMP DEFAULT now()
);

CREATE OR REPLACE FUNCTION trg_bill_total_stmt()
RETURNS TRIGGER AS $$
DECLARE
  rec RECORD;
BEGIN
  FOR rec IN
    (SELECT DISTINCT bill_id FROM new_table
     UNION
     SELECT DISTINCT bill_id FROM old_table)
  LOOP
    INSERT INTO bill_audit(bill_id, old_total, new_total, changed_at)
    SELECT b.id,
           b.total AS old_total,
           COALESCE((SELECT SUM(amount) FROM bill_item WHERE bill_id = b.id), 0) AS new_total,
           now()
    FROM bill b
    WHERE b.id = rec.bill_id;

    UPDATE bill b
      SET total = COALESCE((SELECT SUM(amount) FROM bill_item WHERE bill_id = rec.bill_id), 0)
    WHERE b.id = rec.bill_id;
  END LOOP;

  RETURN NULL;
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_bill_total_stmt ON bill_item;

CREATE TRIGGER trg_bill_total_stmt
AFTER INSERT OR UPDATE OR DELETE ON bill_item
REFERENCING NEW TABLE AS new_table OLD TABLE AS old_table
FOR EACH STATEMENT
EXECUTE FUNCTION trg_bill_total_stmt();

INSERT INTO bill VALUES (1, 0);
INSERT INTO bill VALUES (2, 0);

INSERT INTO bill_item(bill_id, amount) VALUES
  (1, 50), (1, 100),
  (2, 40), (2, 60);

SELECT * FROM bill ORDER BY id;

UPDATE bill_item SET amount = amount + 10 WHERE bill_id = 1;
SELECT * FROM bill ORDER BY id;

DELETE FROM bill_item WHERE bill_id = 2 AND amount = 40;
SELECT * FROM bill ORDER BY id;
SELECT * FROM bill_audit ORDER BY changed_at;
