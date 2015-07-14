@echo off

call _var.bat

set OUTPUT=%METAVER%\02-procedures.sql

if "%STDOUT_REDIRECTED%" == "" (
    set STDOUT_REDIRECTED=yes
    cmd.exe /c %0 %* >%OUTPUT%
    exit /b %ERRORLEVEL%
)

rem 
call :read_settings %~dp0\%METAVER%\02-procedures.lst|| exit /b 1

rem ����� �� ��������. ������ - ������ �������.
exit /b 0

rem
rem ������� ��� ������ �������� �� �����.
rem ����:
rem       %1           - ��� ����� � �����������
:read_settings

set PRC_DIR=%METAVER%\02-procedures
set SETTINGSFILE=%1

rem �������� ������������� �����
if not exist %SETTINGSFILE% (
    echo FAIL: ���� � ����������� �����������
    exit /b 1
)

if not exist %PRC_DIR% (mkdir  %PRC_DIR%)

del /Q %PRC_DIR%\*.*

for /f "eol=# delims== tokens=1" %%i in (%SETTINGSFILE%) do (
  echo INPUT '..\sql-mdo\%PRC_DIR%\%%i';

  rem echo  .\prc\%%i
  rem echo ..\..\prc\%%i

    copy prc\%%i /B /Y  %PRC_DIR%  > nul
)
echo COMMIT;

exit /b 0