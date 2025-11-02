-- Task 08: Hierarchy Table

-- Hierarchy table
CREATE TABLE hier(
  parent_id INT,
  child_id INT,
  PRIMARY KEY(parent_id, child_id)
);

INSERT INTO hier(parent_id, child_id) VALUES
 (1,2),(1,3),(2,4),(2,5),(3,6),(3,7);

-- Knowledge base table
CREATE TABLE triple(
  s VARCHAR(64),
  p VARCHAR(64),
  o VARCHAR(64)
);

INSERT INTO triple(s,p,o) VALUES
 ('payment','isA','financial_event'),
 ('financial_event','isA','event'),
 ('momo','isA','payment_mode'),
 ('bank','isA','payment_mode'),
 ('hostel','isA','facility'),
 ('room','isA','facility'),
 ('facility','isA','entity'),
 ('student','isA','person');

