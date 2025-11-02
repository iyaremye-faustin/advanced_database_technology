
-- =========================================
-- Task 1 (PostgreSQL): Rules - Safe Prescriptions
-- =========================================
SET client_min_messages = WARNING;

CREATE SCHEMA IF NOT EXISTS healthnet;
SET search_path = healthnet;

DROP TABLE IF EXISTS patient_med CASCADE;
DROP TABLE IF EXISTS patient CASCADE;

CREATE TABLE patient (
  id   INTEGER PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE patient_med (
  patient_med_id INTEGER PRIMARY KEY,
  patient_id     INTEGER NOT NULL REFERENCES patient(id),
  med_name       VARCHAR(80) NOT NULL,
  dose_mg        NUMERIC(6,2) CHECK (dose_mg >= 0),
  start_dt       DATE NOT NULL,
  end_dt         DATE NOT NULL,
  CONSTRAINT ck_rx_dates CHECK (start_dt <= end_dt)
);

INSERT INTO patient(id, name) VALUES (1, 'Jane Doe');

DO $$
BEGIN
  BEGIN
    INSERT INTO patient_med(patient_med_id, patient_id, med_name, dose_mg, start_dt, end_dt)
    VALUES (10, 1, 'Amoxicillin', -5, date '2025-01-10', date '2025-01-20');
  EXCEPTION WHEN others THEN RAISE NOTICE 'Expected failure (negative dose): %', SQLERRM; END;

  BEGIN
    INSERT INTO patient_med(patient_med_id, patient_id, med_name, dose_mg, start_dt, end_dt)
    VALUES (11, 1, 'Ibuprofen', 200, date '2025-02-10', date '2025-02-01');
  EXCEPTION WHEN others THEN RAISE NOTICE 'Expected failure (inverted dates): %', SQLERRM; END;

  BEGIN
    INSERT INTO patient_med(patient_med_id, patient_id, med_name, dose_mg, start_dt, end_dt)
    VALUES (12, 1, NULL, 100, date '2025-03-01', date '2025-03-10');
  EXCEPTION WHEN others THEN RAISE NOTICE 'Expected failure (null med_name): %', SQLERRM; END;

  BEGIN
    INSERT INTO patient_med(patient_med_id, patient_id, med_name, dose_mg, start_dt, end_dt)
    VALUES (13, 999, 'Paracetamol', 500, date '2025-04-01', date '2025-04-05');
  EXCEPTION WHEN others THEN RAISE NOTICE 'Expected failure (FK): %', SQLERRM; END;
END$$;

INSERT INTO patient_med VALUES (20, 1, 'Paracetamol',   500, date '2025-04-01', date '2025-04-05');
INSERT INTO patient_med VALUES (21, 1, 'Ciprofloxacin',   0, date '2025-05-01', date '2025-05-01');

TABLE patient_med;
