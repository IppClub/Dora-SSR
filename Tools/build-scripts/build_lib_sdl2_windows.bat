@echo off
setlocal

set BUILD_MODE=release
if /I "%~1"=="debug" set BUILD_MODE=debug
if /I "%~1"=="release" set BUILD_MODE=release

where xmake >nul 2>nul
if errorlevel 1 (
	echo xmake executable not found, unable to build SDL2 libraries.
	exit /b 1
)

set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%..\..\Source\3rdParty\SDL2"

xmake f -c -p windows -a x86 -m %BUILD_MODE% -y
if errorlevel 1 exit /b %errorlevel%

xmake build -j 8 SDL2
if errorlevel 1 exit /b %errorlevel%

if /I "%BUILD_MODE%"=="debug" (
	set OUT_DIR=Lib\Windows\Debug
) else (
	set OUT_DIR=Lib\Windows\Release
)

if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"
copy /Y "build\windows\x86\%BUILD_MODE%\SDL2.lib" "%OUT_DIR%\SDL2.lib" >nul
if errorlevel 1 exit /b %errorlevel%

echo Built SDL2 library in Source\3rdParty\SDL2\%OUT_DIR%
