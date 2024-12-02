set SCRIPT_DIR=%~dp0
set SUBDIR_PATH=%SCRIPT_DIR%..\..\Source\Rust
cd %SUBDIR_PATH%
cargo build --release --target i686-pc-windows-msvc
copy target\i686-pc-windows-msvc\release\dora_runtime.lib lib\Windows\dora_runtime.lib

