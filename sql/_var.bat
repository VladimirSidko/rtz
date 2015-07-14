@set SQL_DIR=..\sql-mdo
@set FDB_FILE=..\fdb\mdo.fdb
@set FDB_USER=-user SYSDBA -password masterkey
@set LOG_DIR=..\log
@set ERR_FILE=%LOG_DIR%\mdo_db_error.txt
@set METAVER=001
IF NOT EXIST %LOG_DIR% MKDIR %LOG_DIR%
