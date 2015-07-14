SET BACKUP_PATH=C:\arch\MDS3050.SERVER_2010.11.29
SET SERVER_PATH=C:\3050MDS\3050MDS.SRV
SET CLIENT_PATH=C:\3050MDS\3050MDO.GIT\user-distr
SET SOURCE_SQL_PATH=C:\3050MDS\3050MDO.GIT\sql
SET MDO_INSTALL_PATH=C:\Program Files\Morion\MDS3050\2.0\

rem грохаем старые пакеты
del /S /Q C:\3050MDS\3050MDS.SRV\upd\new\*.7z

rem восстанавливаем старую инсталяцию
copy /Y D:\inbound\inbound\MDS3050.SRV.FDB  %SERVER_PATH%\fdb\MDS3050.SRV
xcopy /Y %BACKUP_PATH%\bin\mdo_sync.exe  %SERVER_PATH%\bin\mdo_sync.exe
xcopy /Y %BACKUP_PATH%\sql-mdo\_sql*.sql %SERVER_PATH%\sql-mdo\

IF %ERRORLEVEL% NEQ 0 PAUSE

rem сбрасываем настройки сервера на исходные значения
inifile %SERVER_PATH%\cfg\mdo_sync.ini [SyncSettings_other] TopTimeSync=20.11.2010 13:05:48
inifile %SERVER_PATH%\cfg\mdo_sync.ini [SyncSettings_other] BottomTimeSync=20.11.2010 13:05:48
inifile %SERVER_PATH%\cfg\usr-options [Preference] prf_mds_upd_immediate_publish=0
inifile %SERVER_PATH%\cfg\usr-options [Preference] prf_mds_upd_update_server_url=disable
inifile %SERVER_PATH%\cfg\usr-options [Preference] prf_mds_upd_packet_server_ftp=ftp


rem режем финализационные пакеты
cd %SERVER_PATH%\bin\
call mdo_sync.exe /publ /packet_final

IF %ERRORLEVEL% NEQ 0 PAUSE

rem обновляем сервер
xcopy /Y %CLIENT_PATH%\bin\mdo_sync.exe  %SERVER_PATH%\bin\mdo_sync.exe
xcopy /Y /S /E %SOURCE_SQL_PATH%\019       %SERVER_PATH%\sql-mdo\019
xcopy /Y       %SOURCE_SQL_PATH%\_mdo*.sql %SERVER_PATH%\sql-mdo\

rem обновляем серверные метаданные
cd %SERVER_PATH%\sql-mdo\
call update.cmd

rem синхронизируемся на новых метаданных, дорезаем пакеты с рекламой
cd %SERVER_PATH%\bin\
call mdo_sync.exe /sync

PAUSE
