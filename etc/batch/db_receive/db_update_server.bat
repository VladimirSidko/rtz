@REM скрипт для быстрого получения СЕРВЕРНОЙ базы актуальной версии метаданных
@REM работает из корня проекта!

@SET ROOT=%~dp0
@SET SERVER_PATH=%ROOT%3050MDS.SRV
@SET SYNC_DB_NAME=%SERVER_PATH%\fdb\MDS3050.SRV_
@SET MDO_PATH=%ROOT%3050MDO.GIT\user-distr
@SET SOURCE_SQL_PATH=%ROOT%3050MDO.GIT\sql
@SET DB_VER=020
@set finalize_file=..\tmp\finalize.sql

rem добрасываем свежие метаданные
xcopy /Y /E /I %SOURCE_SQL_PATH%\%DB_VER% %SERVER_PATH%\sql-mdo\%DB_VER%
xcopy /Y       %SOURCE_SQL_PATH%\_mdo*.sql   %SERVER_PATH%\sql-mdo
xcopy /Y       %SOURCE_SQL_PATH%\update.sql  %SERVER_PATH%\sql-mdo
xcopy /Y       %SOURCE_SQL_PATH%\execute.cmd %SERVER_PATH%\sql-mdo


copy /Y %SYNC_DB_NAME% %SERVER_PATH%\fdb\MDS3050.SRV
IF %ERRORLEVEL% == 1 PAUSE

cd %SERVER_PATH%\sql-mdo

rem формируем временный скрипт для ручной финализации базы
echo INPUT '..\sql-mdo\connect.sql'; >%finalize_file%
echo UPDATE RPL_LAYER T SET T.FINISHED_VER = (SELECT RESULT FROM SYS_GET_VERSION); >>%finalize_file%
rem echo UPDATE RPL_LAYER T SET T.ID_VER = (SELECT RESULT FROM SYS_GET_VERSION); >>%finalize_file%
echo COMMIT; >>%finalize_file%


cd %SERVER_PATH%\sql-mdo
call execute.cmd %finalize_file%
IF %ERRORLEVEL% == 1 PAUSE

cd %SERVER_PATH%\sql-mdo
call update.cmd
IF %ERRORLEVEL% == 1 PAUSE