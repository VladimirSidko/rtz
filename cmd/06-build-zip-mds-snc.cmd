call setvariables.cmd
%msbuild% /t:BuildSncSrv /p:config=%BUILD_MODE%;ProjConf=mds
