@echo off
start "" /wait "%~dp0Dora.exe" --register-url-handler
if errorlevel 1 (
    echo Could not register Dora SSR links. Keep this script next to Dora.exe.
    pause
    exit /b 1
)
echo Dora SSR can now open dora-ssr links.
pause
