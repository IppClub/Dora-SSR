@echo off
setlocal

set BUILD_MODE=release
if /I "%~1"=="debug" set BUILD_MODE=debug
if /I "%~1"=="release" set BUILD_MODE=release

where xmake >nul 2>nul
if errorlevel 1 (
	echo xmake executable not found, unable to build bgfx libraries.
	exit /b 1
)

set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%..\..\Source\3rdParty\bgfx"

xmake f -c -p windows -a x86 -m %BUILD_MODE% -y
if errorlevel 1 exit /b %errorlevel%

xmake -j8
if errorlevel 1 exit /b %errorlevel%

echo Built bgfx libraries in 'Source\3rdParty\bgfx\build\windows\x86\%BUILD_MODE%'
