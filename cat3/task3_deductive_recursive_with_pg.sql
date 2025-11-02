
-- =========================================
-- Task 3 (PostgreSQL): Deductive DB - Supervision Chain
-- =========================================
SET client_min_messages = WARNING;

DROP TABLE IF EXISTS staff_supervisor CASCADE;

CREATE TABLE staff_supervisor (
  employee   TEXT,
  supervisor TEXT
);

INSERT INTO staff_supervisor VALUES ('Alice',  'Bob');
INSERT INTO staff_supervisor VALUES ('Bob',    'Carol');
INSERT INTO staff_supervisor VALUES ('Carol',  'Diana');
INSERT INTO staff_supervisor VALUES ('Eve',    'Bob');
INSERT INTO staff_supervisor VALUES ('Frank',  'Eve');
-- Optional cycle:
-- INSERT INTO staff_supervisor VALUES ('Diana', 'Bob');

WITH RECURSIVE supers(emp, sup, hops, path) AS (
  SELECT employee, supervisor, 1, '>' || employee || '>'
  FROM   staff_supervisor
  UNION ALL
  SELECT t.emp,
         s.supervisor,
         t.hops + 1,
         t.path || s.supervisor || '>'
  FROM supers t
  JOIN staff_supervisor s
    ON s.employee = t.sup
  WHERE POSITION(('>' || s.supervisor || '>') IN t.path) = 0
),
ranked AS (
  SELECT emp,
         sup AS top_supervisor,
         hops,
         ROW_NUMBER() OVER (PARTITION BY emp ORDER BY hops DESC) AS rn
  FROM supers
)
SELECT emp, top_supervisor, hops
FROM ranked
WHERE rn = 1
ORDER BY emp;
