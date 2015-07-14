@echo off
call _var.bat

if exist %ERR_FILE% call del /q /s %ERR_FILE% >NUL
cd ..\bin

if exist %FDB_FILE% call move /Y %FDB_FILE% "..\fdb\mdo.fdb.backup"
if %ERRORLEVEL% == 1 EXIT 1


rem isql.exe -ch WIN1251 -s 3 -q -b -n -i %SQL_DIR%\create.sql -o %ERR_FILE% -m 

IBEScript.exe %SQL_DIR%\create.sql -V%ERR_FILE% -E


set IF_ERROR=%ERRORLEVEL%

if %IF_ERROR% == 0 call del /q /s %ERR_FILE% >NUL
if %IF_ERROR% == 1 call start notepad %ERR_FILE%
if %IF_ERROR% == 1 EXIT 1
