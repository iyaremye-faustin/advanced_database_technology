# Hostel and Fees Management System Database - EXAMINATION
# 224020737_IYAREMYE_FAUSTIN

## Overview

This project implements a comprehensive relational database for a Hostel Management System designed for educational institutions. The system efficiently manages student accommodations, room assignments, payments, fees, and maintenance requests, providing a complete solution for hostel administration.

## Database Schema Implementation Steps

The database was implemented through a series of carefully planned steps:

### Step 1: Requirements Analysis

Before writing any code, we conducted a thorough analysis of the requirements:

1. **Identified key entities**: Students, hostels, rooms, wardens, payments, etc.
2. **Defined relationships**: How these entities relate to each other
3. **Established business rules**: Constraints and policies that must be enforced
4. **Determined reporting needs**: What information needs to be extracted from the system

### Step 2: Core Schema Design

The first step involved designing the core database schema with the following main components:

#### Academic Program Management
- **Program**: Created a table to store academic programs with fields for name, status, and timestamps.
- **Students**: Implemented a table for student information including personal details, contact information, and program enrollment.
- **Academic Year**: Designed a table to define academic periods with start and end dates.
- **Registration**: Created a table to track student registrations for specific academic years.

#### Hostel Management
- **Hostel**: Developed a table to store information about different hostels, including capacity and gender type.
- **Room**: Implemented a table for room details within hostels, including room number, type, and occupancy status.
- **Warden**: Created a table to manage staff responsible for hostel supervision.
- **Warden_Hostels**: Designed a mapping table to assign wardens to hostels with specific shift schedules.

#### Financial Management
- **Payment_Mode**: Implemented a table to define available payment methods.
- **Payment**: Created a comprehensive table to record student payments for room accommodations.

#### Maintenance Management
- **Maintenance_Request**: Developed a table to track maintenance issues, approvals, and completion status.

### Step 3: Database Features Implementation

After establishing the core schema, the following key features were implemented:

1. **Student Management**: Created tables and relationships to track student information, program enrollment, and academic registration.
2. **Room Allocation**: Implemented a system to manage hostel rooms and their occupancy status with appropriate status tracking.
3. **Staff Management**: Developed functionality to assign wardens to hostels with specific shift schedules.
4. **Payment Processing**: Built a robust system to record and track accommodation payments with various payment methods.
5. **Maintenance Tracking**: Implemented a comprehensive system to log and process maintenance requests for rooms.
6. **Automated Room Status Management**: Created triggers to automatically update room status when payments are confirmed.
7. **Double Allocation Prevention**: Implemented system safeguards to prevent multiple allocations of the same room to different students.
8. **Revenue Reporting**: Developed monthly revenue tracking per hostel using aggregation views.
9. **Maintenance Analysis**: Created queries to identify rooms with recurring maintenance issues.

### Step 4: Data Integrity Implementation

To ensure data quality and consistency, the following constraints were implemented:

- **Foreign Key Constraints**: Added constraints to ensure referential integrity between related tables, such as linking students to programs and rooms to hostels.
- **Check Constraints**: Implemented validation for data values, including gender types (male/female) and various status values (active/inactive, available/occupied).
- **Unique Constraints**: Added constraints to prevent duplicate entries, such as unique email addresses for students and unique names for programs.
- **Default Values**: Set sensible defaults for status fields and timestamps to simplify data entry and ensure consistency.
- **Cascading Deletes**: Implemented automatic cleanup of related records, such as deleting maintenance requests when rooms are deleted.

### Step 5: Business Logic Implementation

The system's business logic was implemented through triggers and functions:

1. **prevent_double_allocation()**: Created a trigger function that prevents multiple allocations of the same room and automatically updates room status to 'occupied' when payment is confirmed.
2. **Audit Logging**: Implemented triggers to track changes to critical tables for security and accountability purposes.
3. **Business Limits**: Added constraints to enforce business rules, such as preventing overbooking of rooms.

### Step 6: Reporting System Implementation

To facilitate data analysis and reporting, the following views were created:

- **hostel_revenue_monthly**: Developed a view that summarizes revenue by hostel and month, allowing administrators to track financial performance.

### Step 7: Advanced Query Development

To support operational needs, several advanced queries were developed:

#### Room Occupancy with Payment Status

```sql
WITH last_payment AS (
  SELECT DISTINCT ON (p.room_id)
         p.room_id, p.status AS payment_status, p.amount, p.paid_at, p.student_id
  FROM payment p
  ORDER BY p.room_id, COALESCE(p.paid_at, NOW()) DESC, p.id DESC
)
SELECT
  r.id AS room_id,
  r.room_number,
  h.name AS hostel_name,
  lp.payment_status,
  lp.amount,
  lp.paid_at,
  s.first_name || ' ' || s.last_name AS last_paying_student
FROM room r
JOIN hostel h ON h.id = r.hostel_id
LEFT JOIN last_payment lp ON lp.room_id = r.id
LEFT JOIN students s ON s.id = lp.student_id
WHERE r.status = 'occupied'
ORDER BY h.name, r.room_number;
```

This query uses a Common Table Expression (CTE) with DISTINCT ON to find the most recent payment for each room, then joins this with room and student information to provide a complete view of room occupancy and payment status.

#### Rooms with Repeated Maintenance Issues

```sql
SELECT
  r.id AS room_id,
  r.room_number,
  h.name AS hostel_name,
  COUNT(*) AS request_count
FROM maintenance_request mr
JOIN room r ON r.id = mr.room_id
JOIN hostel h ON h.id = r.hostel_id
GROUP BY r.id, r.room_number, h.name
HAVING COUNT(*) > 1
ORDER BY request_count DESC, hostel_name, room_number;
```

This query identifies rooms with multiple maintenance requests, helping facility managers identify problematic rooms that may need more thorough repairs or replacement.

### Step 8: Advanced Database Features Implementation

The implementation also included several advanced PostgreSQL features:

1. **Table Partitioning**: Implemented table partitioning for large tables to improve query performance.
2. **Audit Logging**: Created a comprehensive audit logging system to track changes to critical tables.
3. **Business Rules**: Implemented business rules as constraints and triggers to enforce data integrity.
4. **Foreign Data Wrapper**: Set up FDW to connect to external data sources when needed.
5. **Distributed Joins**: Optimized queries involving joins across distributed data.
6. **Performance Optimization**: Compared parallel vs. serial query execution for performance tuning.
7. **Transaction Management**: Implemented two-phase commit for critical transactions.
8. **Lock Management**: Added diagnostics for identifying and resolving lock conflicts.
9. **Rule-Based System**: Implemented and tested rules for automated data processing.

## Detailed Database Components

### Tables

#### Academic Program Management

##### Program
- **Purpose**: Stores information about academic programs offered by the institution
- **Key Fields**: id, name, status, created_at, updated_at
- **Constraints**: Unique program names, status must be 'active' or 'closed'
- **Relationships**: One program can have many students

##### Students
- **Purpose**: Stores personal information about students and their program enrollment
- **Key Fields**: id, first_name, last_name, email, telephone, nationality, date_of_birth, gender, date_registered, program_id
- **Constraints**: Unique email addresses, gender must be 'male' or 'female'
- **Relationships**: Each student belongs to one program, can have many registrations and payments

##### Academic Year
- **Purpose**: Defines academic periods for the institution
- **Key Fields**: id, name, start_date, end_date, status
- **Constraints**: Unique academic year names, status must be 'active' or 'closed'
- **Relationships**: One academic year can have many registrations

##### Registration
- **Purpose**: Tracks student registrations for specific academic years
- **Key Fields**: id, student_id, academic_year_id, registration_date
- **Constraints**: Foreign keys to students and academic years
- **Relationships**: Links students to academic years

#### Hostel Management

##### Hostel
- **Purpose**: Stores information about different hostels
- **Key Fields**: id, name, capacity, gender_type
- **Constraints**: Unique hostel names, gender_type must be 'single' or 'mixed'
- **Relationships**: One hostel can have many rooms and warden assignments

##### Room
- **Purpose**: Contains details about individual rooms within hostels
- **Key Fields**: id, hostel_id, room_number, type, status
- **Constraints**: Unique room numbers within each hostel, status must be 'available' or 'occupied'
- **Relationships**: Each room belongs to one hostel, can have many payments and maintenance requests

##### Warden
- **Purpose**: Manages staff responsible for hostel supervision
- **Key Fields**: id, first_name, last_name, telephone, gender, status
- **Constraints**: Unique telephone numbers, gender must be 'male' or 'female', status must be 'active' or 'inactive'
- **Relationships**: One warden can supervise many hostels

##### Warden_Hostels
- **Purpose**: Maps wardens to the hostels they supervise
- **Key Fields**: id, hostel_id, warden_id, shift_start_time, shift_end_time, status
- **Constraints**: Status must be 'active' or 'inactive'
- **Relationships**: Links wardens to hostels with shift information

#### Financial Management

##### Payment_Mode
- **Purpose**: Defines available payment methods
- **Key Fields**: id, name, status
- **Constraints**: Unique payment mode names, status must be 'available' or 'unavailable'
- **Relationships**: One payment mode can be used for many payments

##### Payment
- **Purpose**: Records student payments for room accommodations
- **Key Fields**: id, payment_mode_id, amount, room_id, student_id, status, paid_at
- **Constraints**: Status must be 'paid' or 'unpaid'
- **Relationships**: Each payment is linked to one payment mode, one room, and one student

#### Maintenance Management

##### Maintenance_Request
- **Purpose**: Tracks maintenance issues, approvals, and completion status
- **Key Fields**: id, room_id, warden_id, issue, estimate_amount, status
- **Constraints**: Status must be 'pending', 'approved', 'completed', or 'cancelled'
- **Relationships**: Each maintenance request is linked to one room and optionally to one warden

### Triggers and Functions

#### prevent_double_allocation()
- **Purpose**: Prevents multiple allocations of the same room and updates room status
- **Trigger Events**: Before INSERT or UPDATE on payment
- **Actions**:
  - Checks if a student already has a paid allocation
  - Prevents double allocation by raising an exception
  - Updates room status to 'occupied' when payment is confirmed

### Views

#### hostel_revenue_monthly
- **Purpose**: Summarizes revenue by hostel and month
- **Fields**: hostel_id, hostel_name, month_start, total_paid
- **Source Tables**: payment, room, hostel
- **Aggregation**: SUM of payment amounts grouped by hostel and month

## SQL Implementation 


This file establishes the foundation of our database by creating all the necessary tables with their relationships:

- **Program**: Stores academic programs with name, status, and timestamps
- **Students**: Contains student personal details linked to programs
- **Academic Year**: Defines academic periods with start/end dates
- **Registration**: Links students to academic years
- **Hostel**: Stores hostel information including capacity and gender type
- **Room**: Contains room details within hostels
- **Warden**: Manages staff responsible for hostel supervision
- **Warden_Hostels**: Maps wardens to hostels with shift schedules
- **Payment_Mode**: Defines payment methods
- **Payment**: Records student payments for rooms
- **Maintenance_Request**: Tracks maintenance issues and their status

Each table includes appropriate constraints and indexes to ensure data integrity and query performance.

### 2. Additional Constraints

This file adds more complex constraints beyond those defined in the core schema:

- Additional foreign key constraints
- Complex check constraints
- Business rule constraints
- Exclusion constraints


### 3. Table Partitioning 


- Partitions large tables by date ranges
- Creates appropriate indexes on partitioned tables
- Sets up inheritance hierarchies
- Configures partition routing rules

Partitioning improves query performance for large tables by dividing them into smaller, more manageable chunks.

### 4. Audit Logging


- Creates audit tables to track changes
- Implements audit triggers on critical tables
- Records user information, timestamps, and change details
- Provides functions to query audit history

The audit system ensures accountability by tracking who made changes to critical data and when.

### 5. Business Rules

- Implements occupancy limits for hostels
- Enforces payment deadlines
- Restricts room assignments based on gender
- Manages warden shift scheduling rules

These rules ensure that the database enforces business policies consistently.

### 6. Room Allocation Protection

- Creates the prevent_double_allocation() function
- Sets up a trigger on the payment table
- Automatically updates room status when payment is confirmed
- Prevents a student from being assigned multiple rooms

### 7. Revenue Reporting

- Implements the hostel_revenue_monthly view
- Aggregates payment data by hostel and month
- Provides a clear summary of financial performance
- Supports management decision-making

This view makes it easy to track revenue trends over time.

### 8. Hierarchical Data

- Creates recursive queries for organizational hierarchies
- Implements tree traversal functions
- Manages parent-child relationships
- Supports hierarchical reporting


### 9. Foreign Data Wrapper

- Sets up connections to external data sources
- Creates foreign tables
- Configures authentication
- Establishes mapping between local and remote schemas

FDW allows the database to access and integrate data from external sources.

### 10. Distributed Query Optimization

- Implements efficient join strategies for distributed tables
- Configures query planning for remote data
- Optimizes data transfer between systems
- Creates helper functions for distributed operations

### 11. Performance Comparison

- Provides examples of parallel query plans
- Demonstrates when to use parallel execution
- Shows how to tune parallel query parameters
- Includes benchmark queries for performance testing

### 12. Transaction Management

- Implements prepared transaction handling
- Shows how to manage distributed transactions
- Provides recovery procedures for failed transactions
- Demonstrates transaction coordination across systems

### 13. Lock Management

- Creates functions to detect lock conflicts
- Shows how to analyze blocking queries
- Provides strategies for deadlock resolution
- Implements lock timeout handling

### 14. Rule-Based System

- Creates rules for automatic data updates
- Implements conditional processing logic
- Tests rule execution and conflict resolution
- Provides examples of rule-based automation

## Testing and Optimization

1. **Created seed data**: To test functionality with realistic data
2. **Tested constraints**: To ensure they correctly enforce business rules
3. **Verified triggers**: To confirm they execute correctly
4. **Optimized queries**: To improve performance
5. **Compared parallel vs. serial execution**: To identify optimal execution strategies

## Technical Details

- **Database System**: PostgreSQL 
- **Last Updated**: October 2025
