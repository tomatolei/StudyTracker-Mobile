@echo off
title StudyTracker-Mobile 一键上传（自动识别版本）
cd /d "%~dp0"

where python >nul 2>nul
if %errorlevel%==0 (
    python "%~dp0upload-to-github.py"
) else (
    where py >nul 2>nul
    if %errorlevel%==0 (
        py -3 "%~dp0upload-to-github.py"
    ) else (
        echo [错误] 未检测到 Python。
        echo 请先安装 Python，或确认 py / python 已加入 PATH。
        echo.
        pause
        exit /b 1
    )
)

set "SCRIPT_EXIT=%errorlevel%"
echo.
pause
exit /b %SCRIPT_EXIT%
