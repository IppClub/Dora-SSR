@echo off
setlocal

set BUILD_MODE=%~1
if "%BUILD_MODE%"=="" set BUILD_MODE=release
if /I "%BUILD_MODE%"=="--debug" set BUILD_MODE=debug
if /I "%BUILD_MODE%"=="--release" set BUILD_MODE=release

where xmake >nul 2>nul
if errorlevel 1 (
	echo xmake executable not found, unable to build the Theora decoder.
	exit /b 1
)

set SCRIPT_DIR=%~dp0
set THEORA_DIR=%SCRIPT_DIR%..\..\Source\3rdParty\theora
cd /d "%THEORA_DIR%"
xmake f -c -p windows -a x86 -m %BUILD_MODE% -y
if errorlevel 1 exit /b %errorlevel%
xmake build -j 8 theoradec
if errorlevel 1 exit /b %errorlevel%

if /I "%BUILD_MODE%"=="debug" (set OUT_DIR=Artifacts\Windows\Debug) else (set OUT_DIR=Artifacts\Windows\Release)
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"
copy /Y "build\windows\x86\%BUILD_MODE%\theoradec.lib" "%OUT_DIR%\theoradec.lib" >nul
if errorlevel 1 exit /b %errorlevel%

echo Built Theora decoder for Windows x86 %BUILD_MODE%.
