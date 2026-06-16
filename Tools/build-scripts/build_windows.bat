set SCRIPT_DIR=%~dp0

call "%SCRIPT_DIR%build_lib_sdl2_windows.bat" release
if errorlevel 1 exit /b %errorlevel%

call "%SCRIPT_DIR%build_lib_bgfx_windows.bat" release
if errorlevel 1 exit /b %errorlevel%

set SUBDIR_PATH=%SCRIPT_DIR%..\..\Source\Rust
cd /d %SUBDIR_PATH%
rustup target add i686-pc-windows-msvc
if errorlevel 1 exit /b %errorlevel%

cargo build --release --target i686-pc-windows-msvc
if errorlevel 1 exit /b %errorlevel%

copy target\i686-pc-windows-msvc\release\dora_runtime.lib lib\Windows\dora_runtime.lib
if errorlevel 1 exit /b %errorlevel%

msbuild ..\..\Projects\Windows\Dora.sln -p:Configuration=release
if errorlevel 1 exit /b %errorlevel%

echo Built APP in 'Projects\Windows\build\Release'
