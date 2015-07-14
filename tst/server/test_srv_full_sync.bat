@SET ROOT=%~dp0

SET SERVER_SNAPSHOT=C:\3050MDS.TEST\SERVER_SNAPSHOT

SET SERVER_PATH=C:\3050MDS.TEST\SERVER

SET CLIENT_PATH=C:\3050MDS\3050MDO.GIT\user-distr
SET SOURCE_SQL_PATH=C:\3050MDS\3050MDO.GIT\sql
SET MDO_INSTALL_PATH=C:\Program Files\Morion\MDS3050\TEST\

SET SYNC_DATE=12.03.2011 13:05:48
SET DB_VER=024

rem �஢��塞 ����稥 �⨫��� ��� ।���஢���� ����஥�
rem ��� ������ � inifile, �᫨ �� ����, ࠢ�� 255
inifile.exe
IF %ERRORLEVEL% NEQ 255 EXIT 1

for /F "tokens=1,2 delims==" %%A IN ('inifile  %SERVER_PATH%\cfg\usr-options [Preference] {96507AE9-0732-4507-BCCE-0C5CBF42E6C4}.user') DO SET FB_USER=%%B
for /F "tokens=1,2 delims==" %%A IN ('inifile  %SERVER_PATH%\cfg\usr-options [Preference] {96507AE9-0732-4507-BCCE-0C5CBF42E6C4}.pass') DO SET FB_PASS=%%B
for /F "tokens=1,2 delims==" %%A IN ('inifile  %SERVER_PATH%\cfg\usr-options [Preference] {96507AE9-0732-4507-BCCE-0C5CBF42E6C4}.cstring') DO SET FB_BASE=%%B

rem ��堥� ���� ������
DEL /S /Q %ROOT%\SERVER\upd\new\*.7z

rem ����⠭�������� ����� ���⠫���
copy /Y %SERVER_SNAPSHOT%\fdb\MDS3050.SRV    %SERVER_PATH%\fdb\MDS3050.SRV
xcopy /Y %SERVER_SNAPSHOT%\bin\mdo_sync.exe  %SERVER_PATH%\bin\mdo_sync.exe
xcopy /Y %SERVER_SNAPSHOT%\sql-mdo\_mdo*.sql %SERVER_PATH%\sql-mdo\
xcopy /Y %SERVER_SNAPSHOT%\cfg\mdo_sync.cfg  %SERVER_PATH%\cfg\mdo_sync.cfg
IF %ERRORLEVEL% NEQ 0 PAUSE

rem ���뢠�� ����ன�� �ࢥ� �� ��室�� ���祭��
inifile %SERVER_PATH%\cfg\mdo_sync.ini [SyncSettings_other] TopTimeSync=%SYNC_DATE%
inifile %SERVER_PATH%\cfg\mdo_sync.ini [SyncSettings_other] BottomTimeSync=%SYNC_DATE%

inifile %SERVER_PATH%\cfg\usr-options [Preference] prf_mds_upd_immediate_publish=0
inifile %SERVER_PATH%\cfg\usr-options [Preference] prf_mds_upd_update_server_url=disable
inifile %SERVER_PATH%\cfg\usr-options [Preference] prf_mds_upd_packet_server_ftp=ftp
inifile %SERVER_PATH%\cfg\usr-options [Preference] prf_mds_sync_change_time=True
inifile %SERVER_PATH%\cfg\usr-options [Preference] prf_mds_sync_bottom_time_sync=%SYNC_DATE%

IF %ERRORLEVEL% NEQ 0 PAUSE

rem ०�� 䨭�����樮��� ������
cd %SERVER_PATH%\bin\
call mdo_sync.exe /publ /packet_final


rem ᪠��� ��᫥���� ����� ������
IF EXIST %SERVER_PATH%\updates\mdo_update.exe DEL %SERVER_PATH%\updates\mdo_update.exe
call wget -v -O %SERVER_PATH%\updates\mdo_update.exe  ftp://mds3050devbuild/mds3050/mdo2/DEBUG/mdo_update.exe
IF %ERRORLEVEL% NEQ 0 PAUSE

rem �㡫��㥬 ����� � �����⮬
call mdo_sync.exe /publ /packet_setup /setup_file "%SERVER_PATH%\updates\mdo_update.exe" /runner_file "%SERVER_PATH%\updates\mdo_runner.exe"

IF %ERRORLEVEL% NEQ 0 PAUSE

rem ������塞 �ࢥ�
call wget -v -O %ROOT%\mdo_sync_server.zip  ftp://mds3050devbuild/mds3050/MDO2/DEBUG/mdo_sync_server.zip
IF %ERRORLEVEL% NEQ 0 PAUSE
call "C:\Program Files\7-Zip\7z.exe" x %ROOT%\mdo_sync_server.zip -o%SERVER_PATH% -aoa
IF %ERRORLEVEL% NEQ 0 PAUSE

rem xcopy /Y %CLIENT_PATH%\bin\mdo_sync.exe  %SERVER_PATH%\bin\mdo_sync.exe
rem xcopy /Y /I /E %SOURCE_SQL_PATH%\%DB_VER%       %SERVER_PATH%\sql-mdo\%DB_VER%
rem xcopy /Y       %SOURCE_SQL_PATH%\_mdo*.sql %SERVER_PATH%\sql-mdo\
rem xcopy /Y       %SOURCE_SQL_PATH%\update.sql %SERVER_PATH%\sql-mdo\update.sql
rem xcopy /Y       %SOURCE_SQL_PATH%\..\cfg\mdo\mdo_sync.cfg %SERVER_PATH%\cfg\mdo_sync.cfg

rem ������塞 �ࢥ�� ��⠤����
cd %SERVER_PATH%\sql-mdo\
call update.cmd

IF %ERRORLEVEL% NEQ 0 PAUSE

rem ᨭ�஭����㥬�� �� ����� ��⠤�����, ��१��� ������ � ४�����
cd %SERVER_PATH%\bin\
call mdo_sync.exe /sync
IF %ERRORLEVEL% NEQ 0 PAUSE

call mdo_sync.exe /publ /packet_adv
IF %ERRORLEVEL% NEQ 0 PAUSE


rem �������� ��⮢� ����� � ����
cd %SERVER_PATH%\sql-mdo
call execute.cmd %ROOT%\test_srv_full_sync.sql
IF %ERRORLEVEL% NEQ 0 PAUSE
call mdo_sync.exe /publ 
IF %ERRORLEVEL% NEQ 0 PAUSE

rem �㡫��㥬 ����� � �� ����� �����⮬ - �஢���� ��� ����� ����� �����뢠�� ����୨��
call mdo_sync.exe /publ /packet_setup /setup_file "%SERVER_PATH%\updates\mdo_update.exe" /runner_file "%SERVER_PATH%\updates\mdo_runner.exe"
IF %ERRORLEVEL% NEQ 0 PAUSE

rem 㤠���� ����� ���⠫��� �� PF
DEL /S /Q "%MDO_INSTALL_PATH%"

rem �ந��⠫��� �।����� �����
call %SERVER_SNAPSHOT%\mdo_setup.exe /SILENT /SUPPRESSMSGBOXES /DIR="%MDO_INSTALL_PATH%"

cd %ROOT%
rem ������㥬 ����������� ���������� �१ ���୥�
echo [Preference] > "%MDO_INSTALL_PATH%\cfg\usr-options"
inifile "%MDO_INSTALL_PATH%\cfg\usr-options" [Preference] prf_mds_upd_update_server_url=disable

rem ��������� ���� ��� ��⮢(ᨭ�஭��� � �ࢥ୮�, �� �� �� 墮�� ࠧ��⨯��� ���������)
call copy /Y %SERVER_SNAPSHOT%\fdb\MDO.FDB "%MDO_INSTALL_PATH%\fdb\MDO.FDB"
IF %ERRORLEVEL% NEQ 0 PAUSE

rem ᪮��஢��� ��⮢� ������
IF NOT EXIST "%MDO_INSTALL_PATH%\upd\new\" MD "%MDO_INSTALL_PATH%\upd\new\"
xcopy /Y /I %SERVER_PATH%\upd\new\*.7z "%MDO_INSTALL_PATH%\upd\new\"
IF %ERRORLEVEL% NEQ 0 PAUSE

rem �������� ������ �� ��⮢�� ���⠫�樨
rem call "%MDO_INSTALL_PATH%\bin\mdo_updt.exe" /update
call "%MDO_INSTALL_PATH%\bin\ide3050main.exe" /update /update_path "%MDO_INSTALL_PATH%\upd\new\"

