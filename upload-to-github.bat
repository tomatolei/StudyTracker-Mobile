@echo off
chcp 65001 >nul
echo ========================================
echo   Upload to GitHub
echo ========================================
echo.

REM Check if git is installed
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Git not found. Please install Git first.
    echo Download: https://git-scm.com/
    pause
    exit /b 1
)

echo Git found.
echo.

REM Initialize git repo
echo [1/5] Initialize Git...
git init >nul 2>&1

REM Add all files
echo [2/5] Add files...
git add .

REM Commit
echo [3/5] Commit changes...
git commit -m "v2.1.2 upate"

REM Set branch to master
echo [4/5] Set branch...
git branch -M master >nul 2>&1

REM Set remote URL
git remote set-url origin https://github.com/tomatolei/StudyTracker-Mobile.git >nul 2>&1
if %errorlevel% neq 0 (
    git remote add origin https://github.com/tomatolei/StudyTracker-Mobile.git >nul 2>&1
)

REM Force push to GitHub
echo [5/5] Push to GitHub...
echo.
git push -f origin master

echo.
echo ========================================
if %errorlevel% equ 0 (
    echo Success!
    echo.
    echo View: https://github.com/tomatolei/StudyTracker-Mobile
) else (
    echo Failed. Check network or GitHub account.
    echo.
    echo May need GitHub token:
    echo 1. Open https://github.com/settings/tokens
    echo 2. Generate new Personal Access Token
    echo 3. Use token instead of password
)
echo ========================================
echo.
pause
