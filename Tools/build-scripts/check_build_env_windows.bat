@echo off
setlocal
pushd "%~dp0..\.."
if errorlevel 1 exit /b 1
xmake doctor --platform=windows
set "CHECK_RESULT=%ERRORLEVEL%"
popd
exit /b %CHECK_RESULT%
