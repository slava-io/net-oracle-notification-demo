CONN ADYENSYNC/development;

PROMPT Removing all tables/sequences in ADYENSYNC schema;

BEGIN
  -- Drop all tables
  FOR i IN (SELECT ut.table_name
              FROM USER_TABLES ut) LOOP

    EXECUTE IMMEDIATE 'drop table '|| i.table_name ||' cascade constraints';
  END LOOP;

  -- Drop all sequences
  FOR i IN (SELECT us.sequence_name
              FROM USER_SEQUENCES us) LOOP

    EXECUTE IMMEDIATE 'drop sequence '|| i.sequence_name;
  END LOOP;

  COMMIT;
END;
/

