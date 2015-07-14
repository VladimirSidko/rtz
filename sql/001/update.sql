-- set verion (check)
INSERT INTO SYS_VER(ID, ID_VER_SYNC, VER_APP) VALUES(001, 001, '1.0.0.0');

ROLLBACK;

INPUT '..\sql-mdo\001\00-before.sql';
INPUT '..\sql-mdo\001\01-metabase.sql';
INPUT '..\sql-mdo\001\02-procedures.sql';
INPUT '..\sql-mdo\001\03-triggers.sql';
COMMIT;

INPUT '..\sql-mdo\001\04-comments.sql';
INPUT '..\sql-mdo\001\05-datainit.sql';
INPUT '..\sql-mdo\001\06-datapump.sql';
INPUT '..\sql-mdo\001\07-droplist.sql';
COMMIT;


-- set version
INSERT INTO SYS_VER(ID, ID_VER_SYNC, VER_APP) VALUES(001, 001, '1.0.0.0');
COMMIT;

EXECUTE PROCEDURE SYS_SET_PRIVILEGES;
EXECUTE PROCEDURE SYS_SET_STATISTICS;
COMMIT;

SELECT 'finishing, closing, and going home' AS "updating:"
FROM RDB$DATABASE;
COMMIT;
