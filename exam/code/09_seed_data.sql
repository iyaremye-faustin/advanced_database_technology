-- Task 09: Minimal seed data for testing

INSERT INTO program(name,status) VALUES ('CS','active') ON CONFLICT DO NOTHING;

INSERT INTO students(first_name,last_name,email,telephone,nationality,date_of_birth,gender,date_registered,program_id)
VALUES
 ('Aline','Uwase','aline@example.com','250780000001','RW','2000-01-10','female','2024-09-01',1),
 ('Eric','Nshuti','eric@example.com','250780000002','RW','1999-05-20','male','2024-09-01',1)
ON CONFLICT DO NOTHING;

INSERT INTO academic_year(name,start_date,end_date,status)
VALUES ('AY 2024/25','2024-09-01','2025-06-30','active')
ON CONFLICT DO NOTHING;

INSERT INTO registration(student_id, academic_year_id, registration_date)
VALUES (1,1,'2024-09-02'), (2,1,'2024-09-02')
ON CONFLICT DO NOTHING;

INSERT INTO hostel(name,capacity,gender_type) VALUES ('Kigali Hall',100,'mixed')
ON CONFLICT DO NOTHING;

INSERT INTO room(hostel_id, room_number, type, status)
VALUES (1,'A-101','double','available'),(1,'A-102','double','available')
ON CONFLICT DO NOTHING;

INSERT INTO warden(first_name,last_name,telephone,gender,status)
VALUES ('Jane','Doe','250780000010','female','active')
ON CONFLICT DO NOTHING;

INSERT INTO warden_hostels(hostel_id,warden_id,shift_start_time,shift_end_time,status)
VALUES (1,1,'08:00','16:00','active')
ON CONFLICT DO NOTHING;

INSERT INTO payment_mode(name,status) VALUES ('momo','available') ON CONFLICT DO NOTHING;
INSERT INTO payment_mode(name,status) VALUES ('bank','available') ON CONFLICT DO NOTHING;

INSERT INTO payment(payment_mode_id,amount,room_id,student_id,status,paid_at)
VALUES
 (1,120.00,1,1,'paid',now()-interval '20 days'),
 (2,120.00,2,2,'paid',now()-interval '18 days'),
 (1,120.00,1,1,'unpaid',NULL),
 (2,80.00,2,2,'unpaid',NULL);
