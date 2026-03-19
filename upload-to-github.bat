@echo off
cd /d "%~dp0"
python "%~dp0upload-to-github.py"
set "SCRIPT_EXIT=%errorlevel%"
echo.
pause
exit /b %SCRIPT_EXIT%
