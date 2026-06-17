set SCRIPT_DIR=%~dp0
set PROJECT_DIR=%SCRIPT_DIR%..\..
set WA_DIR=%PROJECT_DIR%\Source\3rdParty\Wa\Source
set OUTPUT_DIR=%PROJECT_DIR%\Source\3rdParty\Wa\Lib\Windows
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

if not exist "%WA_DIR%\go.mod" (
	echo Wa source is missing: %WA_DIR%
	echo Run Tools\build-scripts\sync_wa_source.sh first.
	exit /b 1
)

set GOOS=windows
set GOARCH=386
set CGO_ENABLED=1
set GOFLAGS=-buildvcs=false -mod=vendor
set GO_LDFLAGS=-ldflags="-s -w"
if exist C:\msys64\mingw32\bin\gcc.exe set CC=C:\msys64\mingw32\bin\gcc.exe

mkdir "%OUTPUT_DIR%" 2>nul
cd /d "%WA_DIR%"
go build -trimpath -buildmode=c-shared %GO_LDFLAGS% -o wa.dll
if errorlevel 1 exit /b %errorlevel%

copy /Y wa.dll "%OUTPUT_DIR%\wa.dll"
if errorlevel 1 exit /b %errorlevel%

del /Q wa.dll wa.h 2>nul
