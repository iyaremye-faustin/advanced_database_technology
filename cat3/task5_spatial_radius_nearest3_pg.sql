
-- =========================================
-- Task 5 (PostgreSQL + PostGIS): Spatial - Radius & Nearest-3
-- =========================================
-- Requires: CREATE EXTENSION postgis;
SET client_min_messages = WARNING;

CREATE EXTENSION IF NOT EXISTS postgis;

DROP TABLE IF EXISTS clinic CASCADE;

CREATE TABLE clinic (
  id   INTEGER PRIMARY KEY,
  name TEXT,
  geom geometry(Point, 4326)
);

CREATE INDEX IF NOT EXISTS clinic_gix ON clinic USING GIST (geom);

INSERT INTO clinic VALUES
  (1, 'Kacyiru Clinic',        ST_SetSRID(ST_MakePoint(30.0605, -1.9565), 4326)),
  (2, 'CHUK',                  ST_SetSRID(ST_MakePoint(30.0615, -1.9580), 4326)),
  (3, 'Polyclinic of Kigali',  ST_SetSRID(ST_MakePoint(30.0680, -1.9525), 4326)),
  (4, 'King Faisal Hospital',  ST_SetSRID(ST_MakePoint(30.0850, -1.9400), 4326));

WITH a AS (
  SELECT ST_SetSRID(ST_MakePoint(30.0600, -1.9570), 4326)::geography AS g
)
SELECT c.id, c.name
FROM clinic c, a
WHERE ST_DWithin(c.geom::geography, a.g, 1000)
ORDER BY c.id;

WITH a AS (
  SELECT ST_SetSRID(ST_MakePoint(30.0600, -1.9570), 4326)::geography AS g
)
SELECT c.id,
       c.name,
       ROUND(ST_Distance(c.geom::geography, a.g) / 1000.0, 3) AS km
FROM clinic c, a
ORDER BY km
LIMIT 3;
