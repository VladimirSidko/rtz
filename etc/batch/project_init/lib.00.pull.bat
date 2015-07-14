echo Refresh sources in %1 to %2
cd %1
call git fetch origin
IF %ERRORLEVEL% NEQ 0 EXIT 1
call git checkout -f %2
IF %ERRORLEVEL% NEQ 0 EXIT 1
cd %PROJ_ROOT%
