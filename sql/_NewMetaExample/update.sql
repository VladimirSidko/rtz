-- set verion (check)
INSERT INTO SYS_VER(ID, ID_VER_SYNC, VER_APP) VALUES(M#, *S#, '*V#');

ROLLBACK;

INPUT '..\sql-mdo\*M#\00-before.sql';
INPUT '..\sql-mdo\*M#\01-metabase.sql';
INPUT '..\sql-mdo\*M#\02-procedures.sql';
INPUT '..\sql-mdo\*M#\03-triggers.sql';
COMMIT;

INPUT '..\sql-mdo\*M#\05-datainit.sql';
INPUT '..\sql-mdo\*M#\06-datapump.sql';
INPUT '..\sql-mdo\*M#\07-droplist.sql';
COMMIT;


-- set version
INSERT INTO SYS_VER(ID, ID_VER_SYNC, VER_APP) VALUES(M#, *S#, '*V#');
COMMIT;

EXECUTE PROCEDURE SYS_SET_PRIVILEGES;
EXECUTE PROCEDURE SYS_SET_STATISTICS;
COMMIT;

SELECT 'finishing, closing, and going home' AS "updating:"
FROM RDB$DATABASE;
COMMIT;
