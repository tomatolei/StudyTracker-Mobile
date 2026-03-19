@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

set "REPO_URL=https://github.com/tomatolei/StudyTracker-Mobile.git"
set "TOKEN_FILE=%~dp0.git_token"
set "DEFAULT_MSG=项目更新"

cd /d "%~dp0"

echo ========================================
echo   StudyTracker-Mobile 一键提交到 GitHub
echo ========================================
echo.

REM 检查 Git
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未检测到 Git，请先安装 Git。
    pause
    exit /b 1
)

REM 读取 Token
set "GITHUB_TOKEN="
if exist "%TOKEN_FILE%" (
    set /p GITHUB_TOKEN=<"%TOKEN_FILE%"
    echo [信息] 已从 .git_token 读取 GitHub Token
) else (
    echo [错误] 未找到 .git_token 文件。
    echo 请先在项目根目录创建 .git_token，并填入你的 GitHub PAT。
    pause
    exit /b 1
)

if "%GITHUB_TOKEN%"=="" (
    echo [错误] .git_token 为空，请检查内容。
    pause
    exit /b 1
)

echo.
set /p UPDATE_NOTE=请输入本次更新内容（例如：修复Excel导出和本地保存）: 
if "%UPDATE_NOTE%"=="" set "UPDATE_NOTE=%DEFAULT_MSG%"

set "COMMIT_MSG=update: %UPDATE_NOTE%"
set "AUTH_REPO_URL=https://%GITHUB_TOKEN%@github.com/tomatolei/StudyTracker-Mobile.git"

echo.
echo [1/6] 初始化 Git 仓库（如有需要）
git init >nul 2>&1

echo [2/6] 清理 remote，确保不保留旧 token
git remote remove origin >nul 2>&1
git remote add origin "%REPO_URL%" >nul 2>&1

echo [3/6] 暂存需要提交的源码文件

git add .github\workflows\android-build.yml
git add README.md
git add config.xml
git add help-doc.html
git add package.json
git add package-lock.json
git add upload-to-github.bat
git add www
git add "更新日志-本次修复.md" >nul 2>&1

git rm --cached studytracker.keystore >nul 2>&1

echo.
echo 本次准备提交的变更：
git status --short

echo.
echo [4/6] 提交代码
git commit -m "%COMMIT_MSG%"
if %errorlevel% neq 0 (
    echo.
    echo [提示] 没有新的源码改动可提交。
    echo 可能原因：
    echo   1. 你这次还没改动主项目源码
    echo   2. 改的是 Android Studio 产物目录，脚本不会提交它们
    echo   3. 改动已提交过
    pause
    exit /b 0
)

echo.
echo [5/6] 切换到 main 分支
git branch -M main >nul 2>&1

echo [6/6] 推送到 GitHub
git remote set-url origin "%AUTH_REPO_URL%" >nul 2>&1
git push -u origin main
set "PUSH_RESULT=%errorlevel%"

git remote set-url origin "%REPO_URL%" >nul 2>&1

echo.
echo ========================================
if "%PUSH_RESULT%"=="0" (
    echo [成功] 已推送到 GitHub
    echo 提交说明：%COMMIT_MSG%
    echo 仓库地址：%REPO_URL%
) else (
    echo [失败] 推送失败，请检查网络、Token 或 GitHub 权限。
    echo 远程地址已恢复为不带 token 的安全地址。
)
echo ========================================
echo.
pause
