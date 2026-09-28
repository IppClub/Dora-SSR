set SCRIPT_DIR=%~dp0
set BUILD_MODE=%~1
if "%BUILD_MODE%"=="" set BUILD_MODE=debug
if /I "%BUILD_MODE%"=="--debug" set BUILD_MODE=debug
if /I "%BUILD_MODE%"=="-d" set BUILD_MODE=debug
if /I "%BUILD_MODE%"=="--release" set BUILD_MODE=release
if /I "%BUILD_MODE%"=="-r" set BUILD_MODE=release
if /I "%BUILD_MODE%"=="release" (
	set MSBUILD_CONFIGURATION=Release
) else if /I "%BUILD_MODE%"=="debug" (
	set MSBUILD_CONFIGURATION=Debug
) else (
	echo Usage: %~nx0 [debug^|release]
	exit /b 1
)

call "%SCRIPT_DIR%build_lib_windows.bat" %BUILD_MODE%
if errorlevel 1 exit /b %errorlevel%

cmake -S "%SCRIPT_DIR%..\..\Projects\Windows" -B "%SCRIPT_DIR%..\..\Projects\Windows\build-cmake" -A Win32
if errorlevel 1 exit /b %errorlevel%

cmake --build "%SCRIPT_DIR%..\..\Projects\Windows\build-cmake" --config %MSBUILD_CONFIGURATION% --target Dora --parallel 8
if errorlevel 1 exit /b %errorlevel%

echo Built APP in 'Projects\Windows\build\%MSBUILD_CONFIGURATION%'
