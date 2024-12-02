set SCRIPT_DIR=%~dp0
set SUBDIR_PATH=%SCRIPT_DIR%..\..\Source\Rust
cd %SUBDIR_PATH%
cargo build --target i686-pc-windows-msvc
copy target\i686-pc-windows-msvc\debug\dora_runtime.lib lib\Windows\dora_runtime.lib
msbuild ..\..\Projects\Windows\Dora.sln -p:Configuration=debug
..\..\Projects\Windows\build\Debug\Dora.exe --asset ..\..\Assets
