REM скрипт для получения копии свежей серверной базы 
REM работает из корня проекта!

@SET ROOT=%~dp0
@SET DB_NAME=MDS3050.SRV_

@SET FULL_DB_NAME=%ROOT%\3050MDS.SRV\fdb\%DB_NAME%
@SET TEST_DB_URL=ftp://mds3050-sync/MDS3050.SRV

IF EXIST %FULL_DB_NAME% DEL %FULL_DB_NAME%
wget -v -O %FULL_DB_NAME%  %TEST_DB_URL%

IF %ERRORLEVEL% == 1 PAUSE

