call setvariables.cmd
%msbuild% /t:BuildSrc;CopyFBE;StartApp /p:config=%BUILD_MODE%