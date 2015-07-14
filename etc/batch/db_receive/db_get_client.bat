REM скрипт для получения копии свежей эталонной базы для дальнейше работы с ней (обновление метаданных и т.п.)
REM работает из корня проекта!

@SET ROOT=%~dp0
@SET DB_NAME=MDO.FDB_
@SET FULL_DB_NAME=%ROOT%\3050MDO.GIT\user-distr\fdb\%DB_NAME%
@SET TEST_DB_URL=ftp://mds3050devsync/MDO.FDB/mdo.fdb

IF EXIST %FULL_DB_NAME% DEL %FULL_DB_NAME%
wget -v -O %FULL_DB_NAME%  %TEST_DB_URL%

IF %ERRORLEVEL% == 1 PAUSE

