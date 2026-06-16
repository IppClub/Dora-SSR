@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "SUBDIR_PATH=%SCRIPT_DIR%..\..\Source\Rust"

cd /d "%SUBDIR_PATH%"
cargo build --target i686-pc-windows-msvc
if errorlevel 1 exit /b %errorlevel%

copy target\i686-pc-windows-msvc\debug\dora_runtime.lib lib\Windows\dora_runtime.lib
if errorlevel 1 exit /b %errorlevel%

msbuild ..\..\Projects\Windows\Dora.sln -p:Configuration=Debug
if errorlevel 1 exit /b %errorlevel%

call :stop_running_dora
..\..\Projects\Windows\build\Debug\Dora.exe --asset ..\..\Assets
exit /b %errorlevel%

:stop_running_dora
tasklist /FI "IMAGENAME eq Dora.exe" 2>NUL | find /I "Dora.exe" >NUL
if errorlevel 1 exit /b 0

taskkill /IM Dora.exe /F
if errorlevel 1 exit /b %errorlevel%

:wait_for_dora_exit
timeout /T 1 /NOBREAK >NUL
tasklist /FI "IMAGENAME eq Dora.exe" 2>NUL | find /I "Dora.exe" >NUL
if not errorlevel 1 goto wait_for_dora_exit
exit /b 0
