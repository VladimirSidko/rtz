call setvariables.cmd
%msbuild% /t:CreateKitMDS;CreateKitStpMDS /p:config=%BUILD_MODE%
