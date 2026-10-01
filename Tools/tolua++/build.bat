@echo off
setlocal
pushd "%~dp0..\.."
if errorlevel 1 exit /b 1
xmake build dora-lua-bindings
set "GEN_RESULT=%ERRORLEVEL%"
popd
exit /b %GEN_RESULT%
