@echo off
setlocal
pushd "%~dp0..\.."
if errorlevel 1 exit /b 1
xmake dora-run --platform=windows --arch=x86 -- %*
set "RUN_RESULT=%ERRORLEVEL%"
popd
exit /b %RUN_RESULT%
