@echo off

rem Cargo/rustc cannot reliably create and remove archive temporary
rem directories on network or shared drives such as Parallels PrlSF.
rem Keep the source tree where it is, but put build artifacts on local NTFS.

if defined CARGO_TARGET_DIR (
	set "DORA_CARGO_TARGET_DIR=%CARGO_TARGET_DIR%"
	goto target_ready
)

set "DORA_CARGO_SOURCE_DIR=%CD%"
set "DORA_CARGO_DRIVE_TYPE="
for /f "usebackq delims=" %%D in (`powershell -NoProfile -Command "$root = [System.IO.Path]::GetPathRoot($env:DORA_CARGO_SOURCE_DIR); ([System.IO.DriveInfo]::new($root)).DriveType"`) do set "DORA_CARGO_DRIVE_TYPE=%%D"

if /I "%DORA_CARGO_DRIVE_TYPE%"=="Network" (
	if not defined LOCALAPPDATA (
		echo LOCALAPPDATA is not defined; cannot select a local Cargo target directory.
		exit /b 1
	)
	set "CARGO_TARGET_DIR=%LOCALAPPDATA%\DoraSSR\cargo-target"
	set "DORA_CARGO_TARGET_DIR=%LOCALAPPDATA%\DoraSSR\cargo-target"
) else (
	set "DORA_CARGO_TARGET_DIR=%CD%\target"
)

:target_ready
echo Cargo target directory: "%DORA_CARGO_TARGET_DIR%"
exit /b 0
