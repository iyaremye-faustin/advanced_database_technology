
-- =========================================
-- Task 4 (PostgreSQL): Triples & Ontology - Infectious-Disease Roll-Up
-- =========================================
SET client_min_messages = WARNING;

DROP TABLE IF EXISTS triple CASCADE;

CREATE TABLE triple (
  s TEXT,
  p TEXT,
  o TEXT
);

-- Taxonomy
INSERT INTO triple VALUES ('Influenza',          'isA', 'ViralInfection');
INSERT INTO triple VALUES ('ViralInfection',     'isA', 'InfectiousDisease');
INSERT INTO triple VALUES ('COVID-19',           'isA', 'ViralInfection');
INSERT INTO triple VALUES ('Tuberculosis',       'isA', 'BacterialInfection');
INSERT INTO triple VALUES ('BacterialInfection', 'isA', 'InfectiousDisease');
INSERT INTO triple VALUES ('Migraine',           'isA', 'NeurologicalCondition');

-- Diagnoses
INSERT INTO triple VALUES ('patient1', 'hasDiagnosis', 'Influenza');
INSERT INTO triple VALUES ('patient2', 'hasDiagnosis', 'COVID-19');
INSERT INTO triple VALUES ('patient3', 'hasDiagnosis', 'Tuberculosis');
INSERT INTO triple VALUES ('patient4', 'hasDiagnosis', 'Migraine');
INSERT INTO triple VALUES ('patient5', 'hasDiagnosis', 'InfectiousDisease');

WITH RECURSIVE isa(child, ancestor) AS (
  SELECT s, o FROM triple WHERE p = 'isA'
  UNION ALL
  SELECT i.child, t.o
  FROM isa i
  JOIN triple t ON t.p = 'isA' AND t.s = i.ancestor
),
infectious_patients AS (
  SELECT DISTINCT t.s AS patient_id
  FROM triple t
  LEFT JOIN isa ON t.o = isa.child
  WHERE t.p = 'hasDiagnosis'
    AND (t.o = 'InfectiousDisease' OR isa.ancestor = 'InfectiousDisease')
)
SELECT patient_id
FROM infectious_patients
ORDER BY patient_id;
