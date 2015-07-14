@ECHO OFF

call _var.bat

CD ..\bin

IF EXIST %ERR_FILE% call DEL /Q /S %ERR_FILE% >NUL

ECHO "Shut database down"
call gfix.exe -shut full -force 0 %FDB_FILE% %FDB_USER%
call gfix.exe -online single      %FDB_FILE% %FDB_USER%

ECHO "Execute script %1"
call isql.exe -ch WIN1251 -s 3 -q -b -n -i %1 -o %ERR_FILE% -m

IF %errorlevel% == 1 call start notepad %ERR_FILE%

ECHO "Bring database online"
call gfix.exe -online normal      %FDB_FILE% %FDB_USER%

if %errorlevel% == 1 call start notepad %ERR_FILE%