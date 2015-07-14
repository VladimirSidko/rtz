echo off
@if not exist ..\etc\project-vars.bat copy ..\etc\project-vars.txt ..\etc\project-vars.bat
call ..\etc\project-vars.bat
@set msbuild=msbuild.exe ..\etc\msbuild.xml

if "%BUILD_MODE%" EQU "" (
  @set BUILD_MODE=Debug
)

echo on