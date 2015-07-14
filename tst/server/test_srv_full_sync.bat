@SET ROOT=%~dp0

SET SERVER_SNAPSHOT=C:\3050MDS.TEST\SERVER_SNAPSHOT

SET SERVER_PATH=C:\3050MDS.TEST\SERVER

SET CLIENT_PATH=C:\3050MDS\3050MDO.GIT\user-distr
SET SOURCE_SQL_PATH=C:\3050MDS\3050MDO.GIT\sql
SET MDO_INSTALL_PATH=C:\Program Files\Morion\MDS3050\TEST\

SET SYNC_DATE=12.03.2011 13:05:48
SET DB_VER=024

rem проверяем наличие утилиты для редактирования настроек
rem код вовзрата у inifile, если он есть, равен 255
inifile.exe
IF %ERRORLEVEL% NEQ 255 EXIT 1

for /F "tokens=1,2 delims==" %%A IN ('inifile  %SERVER_PATH%\cfg\usr-options [Preference] {96507AE9-0732-4507-BCCE-0C5CBF42E6C4}.user') DO SET FB_USER=%%B
for /F "tokens=1,2 delims==" %%A IN ('inifile  %SERVER_PATH%\cfg\usr-options [Preference] {96507AE9-0732-4507-BCCE-0C5CBF42E6C4}.pass') DO SET FB_PASS=%%B
for /F "tokens=1,2 delims==" %%A IN ('inifile  %SERVER_PATH%\cfg\usr-options [Preference] {96507AE9-0732-4507-BCCE-0C5CBF42E6C4}.cstring') DO SET FB_BASE=%%B

rem грохаем старые пакеты
DEL /S /Q %ROOT%\SERVER\upd\new\*.7z

rem восстанавливаем старую инсталяцию
copy /Y %SERVER_SNAPSHOT%\fdb\MDS3050.SRV    %SERVER_PATH%\fdb\MDS3050.SRV
xcopy /Y %SERVER_SNAPSHOT%\bin\mdo_sync.exe  %SERVER_PATH%\bin\mdo_sync.exe
xcopy /Y %SERVER_SNAPSHOT%\sql-mdo\_mdo*.sql %SERVER_PATH%\sql-mdo\
xcopy /Y %SERVER_SNAPSHOT%\cfg\mdo_sync.cfg  %SERVER_PATH%\cfg\mdo_sync.cfg
IF %ERRORLEVEL% NEQ 0 PAUSE

rem сбрасываем настройки сервера на исходные значения
inifile %SERVER_PATH%\cfg\mdo_sync.ini [SyncSettings_other] TopTimeSync=%SYNC_DATE%
inifile %SERVER_PATH%\cfg\mdo_sync.ini [SyncSettings_other] BottomTimeSync=%SYNC_DATE%

inifile %SERVER_PATH%\cfg\usr-options [Preference] prf_mds_upd_immediate_publish=0
inifile %SERVER_PATH%\cfg\usr-options [Preference] prf_mds_upd_update_server_url=disable
inifile %SERVER_PATH%\cfg\usr-options [Preference] prf_mds_upd_packet_server_ftp=ftp
inifile %SERVER_PATH%\cfg\usr-options [Preference] prf_mds_sync_change_time=True
inifile %SERVER_PATH%\cfg\usr-options [Preference] prf_mds_sync_bottom_time_sync=%SYNC_DATE%

IF %ERRORLEVEL% NEQ 0 PAUSE

rem режем финализационные пакеты
cd %SERVER_PATH%\bin\
call mdo_sync.exe /publ /packet_final


rem скачать последний пакет апдейта
IF EXIST %SERVER_PATH%\updates\mdo_update.exe DEL %SERVER_PATH%\updates\mdo_update.exe
call wget -v -O %SERVER_PATH%\updates\mdo_update.exe  ftp://mds3050devbuild/mds3050/mdo2/DEBUG/mdo_update.exe
IF %ERRORLEVEL% NEQ 0 PAUSE

rem публикуем пакет с апдейтом
call mdo_sync.exe /publ /packet_setup /setup_file "%SERVER_PATH%\updates\mdo_update.exe" /runner_file "%SERVER_PATH%\updates\mdo_runner.exe"

IF %ERRORLEVEL% NEQ 0 PAUSE

rem обновляем сервер
call wget -v -O %ROOT%\mdo_sync_server.zip  ftp://mds3050devbuild/mds3050/MDO2/DEBUG/mdo_sync_server.zip
IF %ERRORLEVEL% NEQ 0 PAUSE
call "C:\Program Files\7-Zip\7z.exe" x %ROOT%\mdo_sync_server.zip -o%SERVER_PATH% -aoa
IF %ERRORLEVEL% NEQ 0 PAUSE

rem xcopy /Y %CLIENT_PATH%\bin\mdo_sync.exe  %SERVER_PATH%\bin\mdo_sync.exe
rem xcopy /Y /I /E %SOURCE_SQL_PATH%\%DB_VER%       %SERVER_PATH%\sql-mdo\%DB_VER%
rem xcopy /Y       %SOURCE_SQL_PATH%\_mdo*.sql %SERVER_PATH%\sql-mdo\
rem xcopy /Y       %SOURCE_SQL_PATH%\update.sql %SERVER_PATH%\sql-mdo\update.sql
rem xcopy /Y       %SOURCE_SQL_PATH%\..\cfg\mdo\mdo_sync.cfg %SERVER_PATH%\cfg\mdo_sync.cfg

rem обновляем серверные метаданные
cd %SERVER_PATH%\sql-mdo\
call update.cmd

IF %ERRORLEVEL% NEQ 0 PAUSE

rem синхронизируемся на новых метаданных, дорезаем пакеты с рекламой
cd %SERVER_PATH%\bin\
call mdo_sync.exe /sync
IF %ERRORLEVEL% NEQ 0 PAUSE

call mdo_sync.exe /publ /packet_adv
IF %ERRORLEVEL% NEQ 0 PAUSE


rem заливаем тестовые данные в базу
cd %SERVER_PATH%\sql-mdo
call execute.cmd %ROOT%\test_srv_full_sync.sql
IF %ERRORLEVEL% NEQ 0 PAUSE
call mdo_sync.exe /publ 
IF %ERRORLEVEL% NEQ 0 PAUSE

rem публикуем пакет с еще одним апдейтом - проверить как новая версия накатывает бинарники
call mdo_sync.exe /publ /packet_setup /setup_file "%SERVER_PATH%\updates\mdo_update.exe" /runner_file "%SERVER_PATH%\updates\mdo_runner.exe"
IF %ERRORLEVEL% NEQ 0 PAUSE

rem удалить старую инсталяцию из PF
DEL /S /Q "%MDO_INSTALL_PATH%"

rem проинсталить предудущую версию
call %SERVER_SNAPSHOT%\mdo_setup.exe /SILENT /SUPPRESSMSGBOXES /DIR="%MDO_INSTALL_PATH%"

cd %ROOT%
rem блокируем возможность обновления через интернет
echo [Preference] > "%MDO_INSTALL_PATH%\cfg\usr-options"
inifile "%MDO_INSTALL_PATH%\cfg\usr-options" [Preference] prf_mds_upd_update_server_url=disable

rem подложить базу для тестов(синзронную с серверной, что бы был хвост разнотипных изменений)
call copy /Y %SERVER_SNAPSHOT%\fdb\MDO.FDB "%MDO_INSTALL_PATH%\fdb\MDO.FDB"
IF %ERRORLEVEL% NEQ 0 PAUSE

rem скопировать тестовые пакеты
IF NOT EXIST "%MDO_INSTALL_PATH%\upd\new\" MD "%MDO_INSTALL_PATH%\upd\new\"
xcopy /Y /I %SERVER_PATH%\upd\new\*.7z "%MDO_INSTALL_PATH%\upd\new\"
IF %ERRORLEVEL% NEQ 0 PAUSE

rem запустить апдейт на тестовой инсталяции
rem call "%MDO_INSTALL_PATH%\bin\mdo_updt.exe" /update
call "%MDO_INSTALL_PATH%\bin\ide3050main.exe" /update /update_path "%MDO_INSTALL_PATH%\upd\new\"

