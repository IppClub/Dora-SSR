@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "SUBDIR_PATH=%SCRIPT_DIR%..\..\Source\Rust"

call "%SCRIPT_DIR%check_build_env_windows.bat" run
if errorlevel 1 exit /b %errorlevel%

call :ensure_dependencies
if errorlevel 1 exit /b %errorlevel%

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

:ensure_dependencies
set "DEPENDENCY_MISSING="

call :require_file "%SCRIPT_DIR%..\..\Source\3rdParty\SDL2\Lib\Windows\Debug\SDL2.lib"
call :require_file "%SCRIPT_DIR%..\..\Source\3rdParty\bgfx\build\windows\x86\debug\bgfx.lib"
call :require_file "%SCRIPT_DIR%..\..\Source\3rdParty\bgfx\build\windows\x86\debug\bimg.lib"
call :require_file "%SCRIPT_DIR%..\..\Source\3rdParty\bgfx\build\windows\x86\debug\bimg_decode.lib"
call :require_file "%SCRIPT_DIR%..\..\Source\3rdParty\bgfx\build\windows\x86\debug\bx.lib"
call :require_file "%SCRIPT_DIR%..\..\Source\3rdParty\bgfx\build\windows\x86\debug\fcpp.lib"
call :require_file "%SCRIPT_DIR%..\..\Source\3rdParty\bgfx\build\windows\x86\debug\shaderc-lib.lib"
call :require_file "%SCRIPT_DIR%..\..\Source\3rdParty\Wa\Lib\Windows\wa.dll"

if defined DEPENDENCY_MISSING (
	echo Building Windows native dependencies...
	call "%SCRIPT_DIR%build_lib_windows.bat" debug
	if errorlevel 1 exit /b %errorlevel%
)
exit /b 0

:require_file
if not exist "%~1" (
	echo Missing dependency: %~1
	set "DEPENDENCY_MISSING=1"
)
exit /b 0

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
