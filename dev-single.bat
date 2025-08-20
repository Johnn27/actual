@echo off
cd /d "%~dp0"

:: Check if running as admin
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running as administrator - starting development server...
    "C:\Program Files\Git\bin\bash.exe" --login -i -c "yarn start:browser; exec bash"
    pause
) else (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
)