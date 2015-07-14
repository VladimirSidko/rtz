set PATH_BAT=%~dp0
set PATH_BAT_LIB=%PATH_BAT%

set PROJ_NAME=MDS
set PROJ_ROOT=C:\3050MDS

set NAME_IDE=3050IDE.GIT
set NAME_IDF=3050IDF.GIT
set NAME_MDO=3050MDO.GIT
set NAME_VCL=3050VCL.GIT

set PATH_IDE=%PROJ_ROOT%\%NAME_IDE%
set PATH_IDF=%PROJ_ROOT%\%NAME_IDF%
set PATH_MDO=%PROJ_ROOT%\%NAME_MDO%
set PATH_VCL=%PROJ_ROOT%\%NAME_VCL%


IF NOT EXIST %PROJ_ROOT% MD %PROJ_ROOT%
IF NOT EXIST %PROJ_ROOT%\_FB MD %PROJ_ROOT%\_FB
IF %ERRORLEVEL% NEQ 0 EXIT 1

call %PATH_BAT_LIB%\lib.00.clone.bat "git@git.assembla.com:IDE.git" %PATH_IDE%
call %PATH_BAT_LIB%\lib.00.clone.bat "git@git.assembla.com:IDF.git" %PATH_IDF%
call %PATH_BAT_LIB%\lib.00.clone.bat "git@git.assembla.com:MDO.git" %PATH_MDO%
call %PATH_BAT_LIB%\lib.00.clone.bat "git@git.assembla.com:MDS_VCL.git" %PATH_VCL%
IF %ERRORLEVEL% NEQ 0 EXIT 1

call copy %PATH_BAT_LIB%\vars.bat %PROJ_ROOT%
IF %ERRORLEVEL% NEQ 0 EXIT 1

call %PATH_BAT_LIB%\lib.00.pull.bat "%PATH_IDE%" "%BRANCH_IDE%"
call %PATH_BAT_LIB%\lib.00.pull.bat "%PATH_IDF%" "%BRANCH_IDF%"
call %PATH_BAT_LIB%\lib.00.pull.bat "%PATH_MDO%" "%BRANCH_MDO%"
call %PATH_BAT_LIB%\lib.00.pull.bat "%PATH_VCL%" "%BRANCH_VCL%"
IF %ERRORLEVEL% NEQ 0 EXIT 1

cd %PATH_IDE%\etc
copy project-vars.txt project-vars.bat
cd %PROJ_ROOT%

cd %PATH_IDF%\etc
copy project-vars.txt project-vars.bat
cd %PROJ_ROOT%

cd %PATH_MDO%\etc
copy project-vars.txt project-vars.bat
cd %PROJ_ROOT%


