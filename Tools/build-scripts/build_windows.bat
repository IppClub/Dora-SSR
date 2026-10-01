@echo off
setlocal
set "MODE=%~1"
if "%MODE%"=="" set MODE=debug
if /I "%MODE%"=="--debug" set MODE=debug
if /I "%MODE%"=="-d" set MODE=debug
if /I "%MODE%"=="--release" set MODE=release
if /I "%MODE%"=="-r" set MODE=release
pushd "%~dp0..\.."
if errorlevel 1 exit /b 1
xmake dora-build --platform=windows --arch=x86 --mode=%MODE%
set "BUILD_RESULT=%ERRORLEVEL%"
popd
exit /b %BUILD_RESULT%
