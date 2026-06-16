set SCRIPT_DIR=%~dp0

call "%SCRIPT_DIR%build_lib_sdl2_windows.bat" release
if errorlevel 1 exit /b %errorlevel%

set SUBDIR_PATH=%SCRIPT_DIR%..\..\Source\Rust
cd %SUBDIR_PATH%
cargo build --release --target i686-pc-windows-msvc
copy target\i686-pc-windows-msvc\release\dora_runtime.lib lib\Windows\dora_runtime.lib
