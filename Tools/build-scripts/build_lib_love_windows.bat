@echo off
setlocal
set SCRIPT_DIR=%~dp0
set LOVE_DIR=%SCRIPT_DIR%..\..\Source\3rdParty\Love
set BUILD_MODE=%~1
if "%BUILD_MODE%"=="" set BUILD_MODE=release
if /I "%BUILD_MODE%"=="--debug" set BUILD_MODE=debug
if /I "%BUILD_MODE%"=="-d" set BUILD_MODE=debug
if /I "%BUILD_MODE%"=="--release" set BUILD_MODE=release
if /I "%BUILD_MODE%"=="-r" set BUILD_MODE=release
if /I not "%BUILD_MODE%"=="debug" if /I not "%BUILD_MODE%"=="release" (
	echo Usage: %~nx0 [debug^|release]
	exit /b 1
)

pushd "%LOVE_DIR%"
xmake f -c -p windows -a x86 -m %BUILD_MODE% -y
if errorlevel 1 goto :error
xmake build -j 8 love
if errorlevel 1 goto :error
if not exist "Artifacts\Windows" mkdir "Artifacts\Windows"
copy /Y "build\windows\x86\%BUILD_MODE%\love.lib" "Artifacts\Windows\love.lib" >nul
if errorlevel 1 goto :error
popd
exit /b 0

:error
set ERR=%ERRORLEVEL%
popd
exit /b %ERR%
