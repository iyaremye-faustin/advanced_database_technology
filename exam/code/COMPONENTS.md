# Database Components Explained

## Tables

### Academic Program Management

#### Program
- **Purpose**: Stores information about academic programs offered by the institution
- **Key Fields**: id, name, status, created_at, updated_at
- **Constraints**: Unique program names, status must be 'active' or 'closed'
- **Relationships**: One program can have many students

#### Students
- **Purpose**: Stores personal information about students and their program enrollment
- **Key Fields**: id, first_name, last_name, email, telephone, nationality, date_of_birth, gender, date_registered, program_id
- **Constraints**: Unique email addresses, gender must be 'male' or 'female'
- **Relationships**: Each student belongs to one program, can have many registrations and payments

#### Academic Year
- **Purpose**: Defines academic periods for the institution
- **Key Fields**: id, name, start_date, end_date, status
- **Constraints**: Unique academic year names, status must be 'active' or 'closed'
- **Relationships**: One academic year can have many registrations

#### Registration
- **Purpose**: Tracks student registrations for specific academic years
- **Key Fields**: id, student_id, academic_year_id, registration_date
- **Constraints**: Foreign keys to students and academic years
- **Relationships**: Links students to academic years

### Hostel Management

#### Hostel
- **Purpose**: Stores information about different hostels
- **Key Fields**: id, name, capacity, gender_type
- **Constraints**: Unique hostel names, gender_type must be 'single' or 'mixed'
- **Relationships**: One hostel can have many rooms and warden assignments

#### Room
- **Purpose**: Contains details about individual rooms within hostels
- **Key Fields**: id, hostel_id, room_number, type, status
- **Constraints**: Unique room numbers within each hostel, status must be 'available' or 'occupied'
- **Relationships**: Each room belongs to one hostel, can have many payments and maintenance requests

#### Warden
- **Purpose**: Manages staff responsible for hostel supervision
- **Key Fields**: id, first_name, last_name, telephone, gender, status
- **Constraints**: Unique telephone numbers, gender must be 'male' or 'female', status must be 'active' or 'inactive'
- **Relationships**: One warden can supervise many hostels

#### Warden_Hostels
- **Purpose**: Maps wardens to the hostels they supervise
- **Key Fields**: id, hostel_id, warden_id, shift_start_time, shift_end_time, status
- **Constraints**: Status must be 'active' or 'inactive'
- **Relationships**: Links wardens to hostels with shift information

### Financial Management

#### Payment_Mode
- **Purpose**: Defines available payment methods
- **Key Fields**: id, name, status
- **Constraints**: Unique payment mode names, status must be 'available' or 'unavailable'
- **Relationships**: One payment mode can be used for many payments

#### Payment
- **Purpose**: Records student payments for room accommodations
- **Key Fields**: id, payment_mode_id, amount, room_id, student_id, status, paid_at
- **Constraints**: Status must be 'paid' or 'unpaid'
- **Relationships**: Each payment is linked to one payment mode, one room, and one student

### Maintenance Management

#### Maintenance_Request
- **Purpose**: Tracks maintenance issues, approvals, and completion status
- **Key Fields**: id, room_id, warden_id, issue, estimate_amount, status
- **Constraints**: Status must be 'pending', 'approved', 'completed', or 'cancelled'
- **Relationships**: Each maintenance request is linked to one room and optionally to one warden

## Triggers and Functions

### prevent_double_allocation()
- **Purpose**: Prevents multiple allocations of the same room and updates room status
- **Trigger Events**: Before INSERT or UPDATE on payment
- **Actions**:
  - Checks if a student already has a paid allocation
  - Prevents double allocation by raising an exception
  - Updates room status to 'occupied' when payment is confirmed

## Views

### hostel_revenue_monthly
- **Purpose**: Summarizes revenue by hostel and month
- **Fields**: hostel_id, hostel_name, month_start, total_paid
- **Source Tables**: payment, room, hostel
- **Aggregation**: SUM of payment amounts grouped by hostel and month

## Example Queries

### Room Occupancy with Payment Status
- **Purpose**: Shows current room occupancy with payment details
- **Technique**: Uses a CTE with DISTINCT ON to find the most recent payment for each room
- **Result**: Provides a complete view of room occupancy and payment status

### Rooms with Repeated Maintenance Issues
- **Purpose**: Identifies rooms with multiple maintenance requests
- **Technique**: Uses GROUP BY and HAVING to find rooms with more than one maintenance request
- **Result**: Helps identify problematic rooms that may need more thorough repairs
