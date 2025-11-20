@echo off
setlocal EnableExtensions EnableDelayedExpansion

cd /d %~dp0
set "SCRIPT_DIR=%cd%"
set "LUA_BUILD_DIR=%SCRIPT_DIR%\tolua++build\lua-5.1.5"
set "LUA_SRC_DIR=%LUA_BUILD_DIR%\src"
set "LUA_BIN=%SCRIPT_DIR%\lua.exe"
set "LUA_DLL=%SCRIPT_DIR%\lua51.dll"
set "LUA_LIB=%LUA_SRC_DIR%\lua51.lib"
set "LFS_DLL=%SCRIPT_DIR%\lfs.dll"

set "NEED_LUA_BUILD="
if not exist "%LUA_BIN%" set "NEED_LUA_BUILD=1"
if not exist "%LUA_DLL%" set "NEED_LUA_BUILD=1"

if defined NEED_LUA_BUILD (
    call :EnsureMSVC || exit /b 1
    call :BuildLua || exit /b 1
)

if not exist "%LFS_DLL%" (
    if not exist "%LUA_LIB%" (
        call :EnsureMSVC || exit /b 1
        call :BuildLua || exit /b 1
    )
    call :EnsureMSVC || exit /b 1
    call :BuildLfs || exit /b 1
)

"%LUA_BIN%" "%SCRIPT_DIR%\tolua++.lua"
exit /b %errorlevel%

:EnsureMSVC
where cl >nul 2>&1 || (
    echo [ERROR] cl.exe not found. Please run this script from a Visual Studio Developer Command Prompt.
    exit /b 1
)
where link >nul 2>&1 || (
    echo [ERROR] link.exe not found. Please run this script from a Visual Studio Developer Command Prompt.
    exit /b 1
)
where mt >nul 2>&1 || (
    echo [WARNING] mt.exe not found. Lua build may fail if manifests are required.
)
exit /b 0

:BuildLua
if not exist "%LUA_SRC_DIR%" (
    echo [ERROR] Lua source directory not found: %LUA_SRC_DIR%
    exit /b 1
)
echo Building Lua 5.1.5...
pushd "%LUA_BUILD_DIR%" >nul
call etc\luavs.bat .
if errorlevel 1 (
    popd >nul
    echo [ERROR] Lua build failed.
    exit /b 1
)
popd >nul
copy /Y "%LUA_SRC_DIR%\lua.exe" "%LUA_BIN%" >nul
if not exist "%LUA_BIN%" (
    echo [ERROR] Failed to copy lua.exe to %LUA_BIN%
    exit /b 1
)
copy /Y "%LUA_SRC_DIR%\lua51.dll" "%LUA_DLL%" >nul
if not exist "%LUA_DLL%" (
    echo [ERROR] Failed to copy lua51.dll to %LUA_DLL%
    exit /b 1
)
exit /b 0

:BuildLfs
set "LFS_SRC_DIR=%SCRIPT_DIR%\tolua++build\lfs"
set "LFS_BUILD_DLL=%LFS_SRC_DIR%\lfs.dll"
if not exist "%LFS_SRC_DIR%\lfs.c" (
    echo [ERROR] LuaFileSystem source not found at %LFS_SRC_DIR%
    exit /b 1
)
echo Building LuaFileSystem...
pushd "%LFS_SRC_DIR%" >nul
cl /nologo /MD /O2 /W3 /I"%LUA_SRC_DIR%" /c lfs.c
if errorlevel 1 (
    popd >nul
    echo [ERROR] Failed to compile lfs.c.
    exit /b 1
)
link /nologo /DLL /OUT:"%LFS_BUILD_DLL%" lfs.obj "%LUA_LIB%"
set "LINK_RESULT=%ERRORLEVEL%"
del /q lfs.obj >nul 2>&1
popd >nul
if not "%LINK_RESULT%"=="0" (
    echo [ERROR] Failed to link lfs.dll.
    exit /b %LINK_RESULT%
)
if not exist "%LFS_BUILD_DLL%" (
    echo [ERROR] Failed to produce lfs.dll in %LFS_SRC_DIR%.
    exit /b 1
)
copy /Y "%LFS_BUILD_DLL%" "%LFS_DLL%" >nul
if not exist "%LFS_DLL%" (
    echo [ERROR] Failed to copy lfs.dll to %LFS_DLL%
    exit /b 1
)
exit /b 0
