@echo off
taskkill /F /IM sing-box.exe >nul 2>&1
if %errorlevel%==0 (
    echo sing-box.exe terminated successfully.
) else (
    echo sing-box.exe is not running.
)