-- Database Week 6: Backups, Point-in-Time Recovery, and Replication
-- Database: bootcamp


-- STEP 1: VERIFY THE DATABASE


-- Check the students table
SELECT * FROM students;

-- Count the students
SELECT COUNT(*) AS student_count
FROM students;


-- STEP 2: VERIFY WAL ARCHIVING


-- Check WAL configuration
SHOW wal_level;
SHOW archive_mode;
SHOW archive_command;

-- Check WAL archiving statistics
SELECT archived_count,
failed_count,
last_archived_wal,
last_failed_wal
FROM pg_stat_archiver;


-- STEP 3: DISASTER SIMULATION

-- Record the recovery point before the accidental deletion
SELECT now() AS recovery_time,
COUNT(*) AS student_count
FROM students;

-- Simulate accidental data loss
-- DELETE FROM students;

-- Verify the data after the simulated disaster
-- SELECT COUNT(*) FROM students;


-- STEP 4: POINT-IN-TIME RECOVERY VERIFICATION

-- After restoring the database to the recorded recovery time,
-- verify that the students were recovered.

SELECT COUNT(*) AS recovered_student_count
FROM students;

-- STEP 5: STREAMING REPLICATION

-- Create a replication user
-- Run once on the primary database:
-- CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'YOUR_PASSWORD';

-- Check connected standby replicas
SELECT application_name,
state,
pg_wal_lsn_diff(sent_lsn, replay_lsn) AS lag_bytes
FROM pg_stat_replication;

-- STEP 6: FINAL VERIFICATION

-- The expected replication state is:
-- state = streaming
-- lag_bytes = 0 or a very small value

SELECT application_name,
state,
pg_wal_lsn_diff(sent_lsn, replay_lsn) AS lag_bytes
FROM pg_stat_replication;
