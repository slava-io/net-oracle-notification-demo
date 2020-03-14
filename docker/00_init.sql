-- Print current active user
SHOW USER;

-- Force Character set to LATIN9 to be compatible with Vanessa
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER SYSTEM ENABLE RESTRICTED SESSION;
ALTER SYSTEM SET JOB_QUEUE_PROCESSES=1;
ALTER SYSTEM SET AQ_TM_PROCESSES=0;
ALTER DATABASE OPEN;
ALTER DATABASE CHARACTER SET INTERNAL_USE WE8ISO8859P15;
ALTER DATABASE CHARACTER SET WE8ISO8859P15;
ALTER SYSTEM DISABLE RESTRICTED SESSION;

-- Double check character set
SELECT VALUE$ AS CHARACTER_SET
FROM SYS.PROPS$
WHERE NAME = 'NLS_CHARACTERSET';

-- Create ADYENSYNC tablespaces
CREATE TABLESPACE ADYENSYNC
DATAFILE 'ADYENSYNC.DAT'
SIZE 10M AUTOEXTEND ON;

CREATE TEMPORARY TABLESPACE ADYENSYNC_TEMP
TEMPFILE 'ADYENSYNC_TEMP.DAT'
SIZE 5M AUTOEXTEND ON;

-- Create ADYENSYNC user
CREATE USER ADYENSYNC
IDENTIFIED BY development
DEFAULT TABLESPACE ADYENSYNC
TEMPORARY TABLESPACE ADYENSYNC_TEMP;
GRANT UNLIMITED TABLESPACE TO ADYENSYNC;

-- Giving ADYENSYNC user (all) rights
GRANT CREATE SESSION TO ADYENSYNC;
GRANT CREATE TABLE TO ADYENSYNC;
GRANT CREATE CLUSTER TO ADYENSYNC;
GRANT CREATE SYNONYM TO ADYENSYNC;
GRANT CREATE VIEW TO ADYENSYNC;
GRANT CREATE SEQUENCE TO ADYENSYNC;
GRANT CREATE DATABASE LINK TO ADYENSYNC;
GRANT CREATE PUBLIC DATABASE LINK TO ADYENSYNC;
GRANT CREATE PROCEDURE TO ADYENSYNC;
GRANT CREATE TRIGGER TO ADYENSYNC;
GRANT CREATE MATERIALIZED VIEW TO ADYENSYNC;
GRANT CREATE TYPE TO ADYENSYNC;
GRANT CREATE OPERATOR TO ADYENSYNC;
GRANT CREATE INDEXTYPE TO ADYENSYNC;
GRANT CREATE DIMENSION TO ADYENSYNC;
GRANT CREATE ANY CONTEXT TO ADYENSYNC;
GRANT CREATE JOB TO ADYENSYNC;
GRANT CHANGE NOTIFICATION TO ADYENSYNC;
GRANT EXECUTE ON DBMS_CHANGE_NOTIFICATION TO ADYENSYNC;