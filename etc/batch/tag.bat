@REM скрипт для проставления релизной метки ФЗ (по всем уровням - IDE/IDF/MDO...) 
@REM работает из корня проекта!

@SET RLS_VER=2.23.1
@SET RLS_APP=MDS
@SET RLS_CPN=ПК Аптека

@SET TAG_NAME=%RLS_APP%_%RLS_VER%
@SET TAG_ANN=%RLS_CPN% v. %RLS_VER%

@SET CALL_ROOT=%~dp0

@ECHO Do you want to set project tag to %TAG_NAME%?
@SET /p CONFIRM=

IF "%CONFIRM%" NEQ "YES" EXIT

cd %CALL_ROOT%\3050IDE.GIT
call git tag -a -m "%TAG_ANN%" -f %TAG_NAME%
IF %ERRORLEVEL% == 1 PAUSE
call git push --tags
IF %ERRORLEVEL% == 1 PAUSE

cd %CALL_ROOT%\3050IDF.GIT
call git tag -a -m "%TAG_ANN%" -f %TAG_NAME%
IF %ERRORLEVEL% == 1 PAUSE
call git push --tags
IF %ERRORLEVEL% == 1 PAUSE

cd %CALL_ROOT%\3050MDO.GIT
call git tag -a -m "%TAG_ANN%" -f %TAG_NAME%
IF %ERRORLEVEL% == 1 PAUSE
call git push --tags
IF %ERRORLEVEL% == 1 PAUSE

cd %CALL_ROOT%\3050VCL.GIT
call git tag -a -m "%TAG_ANN%" -f %TAG_NAME%
IF %ERRORLEVEL% == 1 PAUSE
call git push --tags
IF %ERRORLEVEL% == 1 PAUSE

