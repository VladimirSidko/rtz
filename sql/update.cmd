call _var.bat

cd ..\bin
if exist %ERR_FILE% call del /q /s %ERR_FILE% >NUL
gfix.exe -shut full -force 0 %FDB_FILE% %FDB_USER%
gfix.exe -online single      %FDB_FILE% %FDB_USER%
isql.exe -ch WIN1251 -s 3 -q -b -n -i %SQL_DIR%\update.sql -o %ERR_FILE% -m

if %errorlevel% == 1 call notepad %ERR_FILE%

gfix.exe -online normal      %FDB_FILE% %FDB_USER%

if %errorlevel% == 1 call notepad %ERR_FILE%