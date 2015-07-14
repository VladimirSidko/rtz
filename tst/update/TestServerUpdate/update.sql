INSERT INTO SYS_VER(ID) VALUES(%VERSION%);

ROLLBACK;

UPDATE M_DRUG T SET T.ID = T.ID WHERE T.ID <> 0;

COMMIT;

-- set version
INSERT INTO SYS_VER(ID) VALUES(%VERSION%);

COMMIT;

EXECUTE PROCEDURE SYS_SET_PRIVILEGES;
EXECUTE PROCEDURE SYS_SET_STATISTICS;

COMMIT;
