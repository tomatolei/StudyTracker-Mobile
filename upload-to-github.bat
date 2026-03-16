@echo off
setlocal enabledelayedexpansion

echo ========================================
echo   Upload to GitHub
echo ========================================
echo.

REM Check git installation
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Git not installed. Download from https://git-scm.com/
    pause
    exit /b 1
)

echo Git found.
echo.

REM Token handling
set "TOKEN_FILE=%~dp0.git_token"
set "GITHUB_TOKEN="
if exist "%TOKEN_FILE%" (
    set /p GITHUB_TOKEN=<"%TOKEN_FILE%"
    echo Token loaded from local file
) else (
    echo Please enter your GitHub Personal Access Token:
    set /p GITHUB_TOKEN="Token: "
    echo !GITHUB_TOKEN!>"%TOKEN_FILE%"
    echo Token saved successfully, no need to enter next time
)

echo [1/5] Initialize Git repository
git init >nul 2>&1

echo [2/5] Add files to commit
git add .

echo [3/5] Commit changes
set "commit_msg=v2.1.2 update"
git commit -m "%commit_msg%" >nul 2>&1
if %errorlevel% neq 0 (
    echo No new changes to commit
    goto :finish
)

echo [4/5] Set master branch
git branch -M master >nul 2>&1

REM Set remote URL with token
set "REPO_URL=https://!GITHUB_TOKEN!@github.com/tomatolei/StudyTracker-Mobile.git"
git remote set-url origin "!REPO_URL!" >nul 2>&1
if %errorlevel% neq 0 (
    git remote add origin "!REPO_URL!" >nul 2>&1
)

echo [5/5] Push to GitHub
echo.
git push -f origin master

:finish
echo.
echo ========================================
if %errorlevel% equ 0 (
    echo Push success!
    echo View at: https://github.com/tomatolei/StudyTracker-Mobile
) else (
    echo Push failed. Please check network or token.
    echo To get token: https://github.com/settings/tokens
)
echo ========================================
echo.
pause
