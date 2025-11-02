-- Task 03: Create Fragment  and  Views

CREATE OR REPLACE VIEW payment_a AS
SELECT * FROM payment WHERE (id % 2) = 0;

CREATE OR REPLACE VIEW payment_b AS
SELECT * FROM payment WHERE (id % 2) = 1;

CREATE OR REPLACE VIEW payment_all AS
SELECT * FROM payment_a
UNION ALL
SELECT * FROM payment_b;

-- Verification
-- SELECT COUNT(*) FROM payment_all;
-- SELECT COUNT(*) FROM payment_a;
-- SELECT COUNT(*) FROM payment_b;
