--- No required to run this because it will run in task2 step


CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE SERVER IF NOT EXISTS branch_b_srv
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (host '127.0.0.1', dbname 'branch_b', port '5432');

-- Map the role you're using in pgAdmin's query tool

CREATE USER MAPPING IF NOT EXISTS FOR postgres
  SERVER branch_b_srv
  OPTIONS (user 'postgres', password 'postgres');


IMPORT FOREIGN SCHEMA public
  LIMIT TO (hostel, room, payment, payment_mode, warden)
  FROM SERVER branch_b_srv
  INTO public;