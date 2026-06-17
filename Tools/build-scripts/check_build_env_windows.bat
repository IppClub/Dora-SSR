@echo off
setlocal

set "SCOPE=%~1"
if "%SCOPE%"=="" set "SCOPE=build"
set "HAS_MISSING="

call :require go "required for Wa"
call :require cargo "required for Rust runtime"
call :require rustup "required for Rust targets"

if /I not "%SCOPE%"=="run" (
	call :require xmake "required for SDL2/bgfx"
)

call :require msbuild "required for Visual Studio build"
call :require gcc "required for Go cgo Windows Wa DLL"

if defined HAS_MISSING (
	echo Install the missing tools and re-run the command.
	exit /b 1
)

exit /b 0

:require
where %~1 >nul 2>nul
if errorlevel 1 (
	if not defined HAS_MISSING (
		echo Missing build environment tools for Windows (%SCOPE%):
		set "HAS_MISSING=1"
	)
	echo   - %~1 (%~2)
)
exit /b 0
