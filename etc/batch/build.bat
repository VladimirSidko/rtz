@REM скрипт для сборки всего проекта (без VCL)
@REM работает из корня проекта!

@SET CALL_ROOT=%~dp0
@SET Define=Debug


CD %CALL_ROOT%\3050IDE.GIT\cmd
call 01-distr-kit.cmd
call setvariables.cmd
call %msbuild% /t:SweepSrc;BuildSrc /p:config=%Define%
IF %ERRORLEVEL% NEQ 0 SET /P ASK= 

CD %CALL_ROOT%\3050IDF.GIT\cmd
call 01-distr-kit.cmd
call setvariables.cmd
call %msbuild% /t:SweepSrc;BuildSrc /p:config=%Define%
IF %ERRORLEVEL% NEQ 0 SET /P ASK= 


CD %CALL_ROOT%\3050MDO.GIT\cmd
rem что собираем - УС или ФЗ
call 01-distr-mdo.cmd
rem call 01-distr-mds.cmd
call setvariables.cmd
call %msbuild% /t:SweepSrc;BuildSrc /p:config=%Define%
IF %ERRORLEVEL% NEQ 0 SET /P ASK= 
