# Database Week 6 — Backups, Point-in-Time Recovery, and Replication

## Overview

This project contains my submission for Database Week 6. The lab focused on protecting a PostgreSQL database using logical backups, WAL archiving, point-in-time recovery (PITR), and streaming replication.

The database used for the lab was **`bootcamp`**, which contained a `students` table with five student records.

## Objectives

The objectives of this lab were to:

* Create and verify a logical database backup.
* Configure and verify WAL archiving.
* Create a PostgreSQL base backup.
* Simulate accidental data loss.
* Recover the database to a specific point in time.
* Create a streaming replication standby.
* Monitor replication health and replication lag.

## Step 1: Logical Backup

A logical backup of the `bootcamp` database was created using PostgreSQL's `pg_dump` utility in custom format.

The backup was then:

1. Listed using `pg_restore --list`.
2. Restored into a separate database called `bootcamp_check`.
3. Verified by checking the restored student records.

The restored database contained **5 students**.

## Step 2: WAL Archiving

WAL archiving was enabled using:

* `wal_level = replica`
* `archive_mode = on`
* `archive_command`

WAL archive files were successfully created in the backup directory.

The PostgreSQL archiver statistics were also checked to verify that WAL files were being archived.

## Step 3: Point-in-Time Recovery

A recovery point was recorded before simulating accidental data loss.

The database initially contained:

**5 students**

The following operation was used to simulate a disaster:

```sql
DELETE FROM students;
```

After the deletion, the student count became:

**0 students**

A base backup and archived WAL files were then used to create a separate recovery environment.

The database was recovered to the recorded point in time.

### PITR Verification

After recovery, the following query was executed:

```sql
SELECT COUNT(*) FROM students;
```

Result:

**5 students**

This confirmed that the database was successfully recovered to the point before the accidental deletion.

## Step 4: Streaming Replication

A PostgreSQL replication user was created on the primary server.

A standby server was then created using:

```bash
pg_basebackup -h 127.0.0.1 -U replicator -D ~/standby -R -P
```

The standby PostgreSQL server was started on a separate port.

## Step 5: Replication Health

Replication was verified on the primary server using:

```sql
SELECT application_name,
       state,
       pg_wal_lsn_diff(sent_lsn, replay_lsn) AS lag_bytes
FROM pg_stat_replication;
```

The final result showed:

```text
application_name | state     | lag_bytes
------------------+-----------+----------
walreceiver       | streaming | 0
```

This confirms that the standby was actively streaming from the primary database with **0 bytes of replication lag** at the time of testing.

## Files in This Repository

```text
week-6-database-assignment/
│
├── answer.sql
├── README.md
│
└── screenshots/
    ├── 01-logical-backup.png
    ├── 02-backup-restore.png
    ├── 03-wal-archiving.png
    ├── 04-pitr-recovery.png
    ├── 05-streaming-replication.png
    └── 06-replication-health.png
```

## Conclusion

This lab demonstrated how PostgreSQL can be protected against data loss using multiple backup and recovery strategies.

The completed lab successfully demonstrated:

* Logical backup and restore
* WAL archiving
* Base backup
* Point-in-time recovery
* Disaster recovery
* Streaming replication
* Replication monitoring

The final replication test showed the standby in a **streaming** state with **0 bytes of lag**.
