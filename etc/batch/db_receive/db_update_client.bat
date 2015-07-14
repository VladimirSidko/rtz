@REM скрипт для быстрого получения базы актуальной версии метаданных
@REM работает, если база была получена посредством db_get_client.bat (т.е. лежит в файле MDO.FDB_)
@REM работает из корня проекта!

@SET ROOT=%~dp0
@SET MDO_DISTR=%ROOT%3050MDO.GIT\user-distr
@SET SYNC_DB_NAME=%MDO_DISTR%\fdb\MDO.FDB_
@SET finalize_file=..\tmp\finalize.sql

cd %MDO_DISTR%\..\cmd\
call 01-distr-mdo.cmd
IF %ERRORLEVEL% == 1 PAUSE

cd %MDO_DISTR%\sql-mdo

rem формируем временный скрипт для ручной финализации базы
echo INPUT '..\sql-mdo\connect.sql'; >%finalize_file%
echo UPDATE RPL_LAYER T SET T.FINISHED_VER = (SELECT RESULT FROM SYS_GET_VERSION); >>%finalize_file%
rem echo UPDATE RPL_LAYER T SET T.ID_VER = (SELECT RESULT FROM SYS_GET_VERSION); >>%finalize_file%
echo COMMIT; >>%finalize_file%

copy /Y %SYNC_DB_NAME% %MDO_DISTR%\fdb\mdo.fdb
IF %ERRORLEVEL% == 1 PAUSE

cd %MDO_DISTR%\sql-mdo
call execute.cmd %finalize_file%
IF %ERRORLEVEL% == 1 PAUSE

cd %MDO_DISTR%\sql-mdo
call update.cmd
IF %ERRORLEVEL% == 1 PAUSE