call _var.bat

cd ..\bin
if exist %ERR_FILE%  call del /q /s %ERR_FILE% >NUL
isql.exe -ch WIN1251 -s 3 -q -i %SQL_DIR%\insert.sql -o %ERR_FILE% -m

if %errorlevel% == 1 call notepad %ERR_FILE%