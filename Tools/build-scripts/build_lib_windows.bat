set SCRIPT_DIR=%~dp0
set BUILD_MODE=%~1
if "%BUILD_MODE%"=="" set BUILD_MODE=debug
if /I "%BUILD_MODE%"=="--debug" set BUILD_MODE=debug
if /I "%BUILD_MODE%"=="-d" set BUILD_MODE=debug
if /I "%BUILD_MODE%"=="--release" set BUILD_MODE=release
if /I "%BUILD_MODE%"=="-r" set BUILD_MODE=release
if /I not "%BUILD_MODE%"=="debug" if /I not "%BUILD_MODE%"=="release" (
	echo Usage: %~nx0 [debug^|release]
	exit /b 1
)

call "%SCRIPT_DIR%check_build_env_windows.bat" lib
if errorlevel 1 exit /b %errorlevel%

call "%SCRIPT_DIR%build_lib_sdl2_windows.bat" %BUILD_MODE%
if errorlevel 1 exit /b %errorlevel%

call "%SCRIPT_DIR%build_lib_bgfx_windows.bat" %BUILD_MODE%
if errorlevel 1 exit /b %errorlevel%

call "%SCRIPT_DIR%build_lib_wa_windows.bat" %BUILD_MODE%
if errorlevel 1 exit /b %errorlevel%

set SUBDIR_PATH=%SCRIPT_DIR%..\..\Source\Rust
cd /d %SUBDIR_PATH%
rustup target add i686-pc-windows-msvc
if errorlevel 1 exit /b %errorlevel%

if /I "%BUILD_MODE%"=="release" (
	cargo build --release --target i686-pc-windows-msvc
) else (
	cargo build --target i686-pc-windows-msvc
)
if errorlevel 1 exit /b %errorlevel%

copy target\i686-pc-windows-msvc\%BUILD_MODE%\dora_runtime.lib lib\Windows\dora_runtime.lib
if errorlevel 1 exit /b %errorlevel%
