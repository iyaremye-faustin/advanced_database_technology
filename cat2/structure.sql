DROP VIEW IF EXISTS hostel_revenue_monthly;
DROP FUNCTION IF EXISTS prevent_double_allocation();
DROP TRIGGER IF EXISTS trg_prevent_double_allocation ON payment;

DROP TABLE IF EXISTS maintenance_request CASCADE;
DROP TABLE IF EXISTS payment CASCADE;
DROP TABLE IF EXISTS payment_mode CASCADE;
DROP TABLE IF EXISTS warden_hostels CASCADE;
DROP TABLE IF EXISTS warden CASCADE;
DROP TABLE IF EXISTS room CASCADE;
DROP TABLE IF EXISTS hostel CASCADE;
DROP TABLE IF EXISTS registration CASCADE;
DROP TABLE IF EXISTS academic_year CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS program CASCADE;


-- ======================
-- Program
-- ======================
CREATE TABLE program (
  id            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name          VARCHAR(50) NOT NULL,
  status        TEXT NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  CONSTRAINT chk_program_status CHECK (status IN ('active','closed')),
  CONSTRAINT uq_program_name UNIQUE (name)
);

-- ======================
-- Students
-- ======================
CREATE TABLE students (
  id               INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  first_name       VARCHAR(50) NOT NULL,
  last_name        VARCHAR(50) NOT NULL,
  email            VARCHAR(100) NOT NULL,
  telephone        VARCHAR(50) NOT NULL,
  nationality      VARCHAR(50) NOT NULL,
  date_of_birth    DATE NOT NULL,
  gender           TEXT NOT NULL,
  date_registered  DATE NOT NULL,
  program_id       INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  CONSTRAINT chk_students_gender CHECK (gender IN ('male','female')),
  CONSTRAINT uq_students_email UNIQUE (email),
  CONSTRAINT fk_students_program
    FOREIGN KEY (program_id) REFERENCES program(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);
CREATE INDEX idx_students_program ON students(program_id);

-- ======================
-- Academic Year
-- ======================
CREATE TABLE academic_year (
  id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name        VARCHAR(50) NOT NULL,
  start_date  DATE NOT NULL,
  end_date    DATE NOT NULL,
  status      TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  CONSTRAINT chk_academic_year_status CHECK (status IN ('active','closed')),
  CONSTRAINT uq_academic_year_name UNIQUE (name)
);

-- ======================
-- Registration
-- ======================
CREATE TABLE registration (
  id                 INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  student_id         INTEGER NOT NULL,
  academic_year_id   INTEGER NOT NULL,
  registration_date  DATE NOT NULL,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  CONSTRAINT fk_registration_student
    FOREIGN KEY (student_id) REFERENCES students(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_registration_academic_year
    FOREIGN KEY (academic_year_id) REFERENCES academic_year(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);
CREATE INDEX idx_reg_student ON registration(student_id);
CREATE INDEX idx_reg_academic_year ON registration(academic_year_id);

-- ======================
-- Hostel
-- ======================
CREATE TABLE hostel (
  id           INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name         VARCHAR(50) NOT NULL,
  capacity     INTEGER NOT NULL DEFAULT 1,
  gender_type  TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  CONSTRAINT chk_hostel_gender_type CHECK (gender_type IN ('single','mixed')),
  CONSTRAINT uq_hostel_name UNIQUE (name)
);

-- ======================
-- Room
-- ======================
CREATE TABLE room (
  id            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  hostel_id     INTEGER NOT NULL,
  room_number   VARCHAR(50) NOT NULL,
  type          VARCHAR(50) NOT NULL,
  status        TEXT NOT NULL DEFAULT 'available',
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  CONSTRAINT chk_room_status CHECK (status IN ('available','occupied')),
  CONSTRAINT uq_room_hostel_number UNIQUE (hostel_id, room_number),
  CONSTRAINT fk_room_hostel
    FOREIGN KEY (hostel_id) REFERENCES hostel(id)
    ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE INDEX idx_room_hostel ON room(hostel_id);

-- ======================
-- Warden
-- ======================
CREATE TABLE warden (
  id           INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  first_name   VARCHAR(50) NOT NULL,
  last_name    VARCHAR(50) NOT NULL,
  telephone    VARCHAR(50) NOT NULL,
  gender       TEXT NOT NULL,
  status       TEXT NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  CONSTRAINT uq_warden_telephone UNIQUE (telephone),
  CONSTRAINT chk_warden_gender CHECK (gender IN ('male','female')),
  CONSTRAINT chk_warden_status CHECK (status IN ('active','inactive'))
);

-- ======================
-- Warden ↔ Hostels 
-- ======================
CREATE TABLE warden_hostels (
  id                INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  hostel_id         INTEGER NOT NULL,
  warden_id         INTEGER NOT NULL,
  shift_start_time  TIME NOT NULL,
  shift_end_time    TIME NOT NULL,
  status            TEXT NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  CONSTRAINT chk_wh_status CHECK (status IN ('active','inactive')),
  CONSTRAINT fk_wh_hostel
    FOREIGN KEY (hostel_id) REFERENCES hostel(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_wh_warden
    FOREIGN KEY (warden_id) REFERENCES warden(id)
    ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE INDEX idx_wh_hostel ON warden_hostels(hostel_id);
CREATE INDEX idx_wh_warden ON warden_hostels(warden_id);

-- ======================
-- Payment Mode
-- ======================
CREATE TABLE payment_mode (
  id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name    VARCHAR(50) NOT NULL,
  status  TEXT NOT NULL DEFAULT 'available',
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  CONSTRAINT chk_payment_mode_status CHECK (status IN ('available','unavailable')),
  CONSTRAINT uq_payment_mode_name UNIQUE (name)
);

-- ======================
-- Payment
-- ======================
CREATE TABLE payment (
  id               INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  payment_mode_id  INTEGER NOT NULL,
  amount           NUMERIC(12,2) NOT NULL DEFAULT 0.00,
  room_id          INTEGER NOT NULL,
  student_id       INTEGER NOT NULL,
  status           TEXT NOT NULL DEFAULT 'unpaid',
  paid_at          TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  CONSTRAINT chk_payment_status CHECK (status IN ('paid','unpaid')),
  CONSTRAINT fk_payment_mode
    FOREIGN KEY (payment_mode_id) REFERENCES payment_mode(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_payment_room
    FOREIGN KEY (room_id) REFERENCES room(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_payment_student
    FOREIGN KEY (student_id) REFERENCES students(id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE INDEX idx_payment_mode ON payment(payment_mode_id);
CREATE INDEX idx_payment_room ON payment(room_id);
CREATE INDEX idx_payment_student ON payment(student_id);

-- ======================
-- Maintenance Request
-- ======================
CREATE TABLE maintenance_request (
  id               INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  room_id          INTEGER NOT NULL,
  warden_id        INTEGER NULL,
  issue            TEXT NOT NULL,
  estimate_amount  NUMERIC(12,2) NOT NULL,
  status           TEXT NOT NULL DEFAULT 'pending',
  created_at       TIMESTAMP NOT NULL DEFAULT now(),
  updated_at       TIMESTAMP NOT NULL DEFAULT now(),
  CONSTRAINT chk_mr_status CHECK (status IN ('pending','approved','completed','cancelled')),
  CONSTRAINT fk_mr_room
    FOREIGN KEY (room_id) REFERENCES room(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_mr_warden
    FOREIGN KEY (warden_id) REFERENCES warden(id)
    ON UPDATE CASCADE ON DELETE SET NULL
);
CREATE INDEX idx_mr_room ON maintenance_request(room_id);
CREATE INDEX idx_mr_warden ON maintenance_request(warden_id);