@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
cd /d "%~dp0"

set "REPO_URL=https://github.com/tomatolei/StudyTracker-Mobile.git"
set "TOKEN_FILE=%~dp0.git_token"
set "DEFAULT_MSG=项目更新"
set "PUSH_RESULT=0"

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

REM 检查 token
if not exist "%TOKEN_FILE%" (
    echo [错误] 未找到 .git_token 文件。
    echo 请先在项目根目录创建 .git_token，并填入 GitHub PAT（需 repo + workflow 权限）。
    pause
    exit /b 1
)

set "GITHUB_TOKEN="
set /p GITHUB_TOKEN=<"%TOKEN_FILE%"
if "%GITHUB_TOKEN%"=="" (
    echo [错误] .git_token 为空，请检查内容。
    pause
    exit /b 1
)

echo [信息] 已读取 GitHub Token

echo.
set /p UPDATE_NOTE=请输入本次更新内容（例如：修复Excel导出和本地保存）: 
if "%UPDATE_NOTE%"=="" set "UPDATE_NOTE=%DEFAULT_MSG%"

set "COMMIT_MSG=update: %UPDATE_NOTE%"
set "AUTH_REPO_URL=https://%GITHUB_TOKEN%@github.com/tomatolei/StudyTracker-Mobile.git"

echo.
echo [1/6] 初始化 Git 仓库（如有需要）
git init >nul 2>&1

echo [2/6] 切换到 main 分支
git branch -M main >nul 2>&1

echo [3/6] 重置远程地址为安全模式
git remote remove origin >nul 2>&1
git remote add origin "%REPO_URL%" >nul 2>&1

echo [4/6] 暂存需要提交的主项目源码

REM 只提交主项目源码，不提交 Android Studio 产物
call :safe_add .github\workflows\android-build.yml
call :safe_add README.md
call :safe_add config.xml
call :safe_add help-doc.html
call :safe_add package.json
call :safe_add package-lock.json
call :safe_add upload-to-github.bat
call :safe_add www
call :safe_add "更新日志-本次修复.md"

REM 如果 keystore 曾被跟踪，确保移出版本控制
for /f %%i in ('git ls-files studytracker.keystore 2^>nul') do git rm --cached studytracker.keystore >nul 2>&1

echo.
echo 本次准备提交的源码变更：
git diff --cached --name-status

REM 判断是否真的有已暂存变更
 git diff --cached --quiet
if %errorlevel% equ 0 (
    echo.
    echo [提示] 当前没有新的主项目源码变更可提交。
    echo 说明：
    echo   - Android Studio 产物目录不会被提交
    echo   - build.ps1 这类本地脚本不会被提交
    echo   - 如果你刚改的是源码，请确认已保存在主项目目录中
    pause
    exit /b 0
)

echo.
echo [5/6] 提交代码
git commit -m "%COMMIT_MSG%"
if %errorlevel% neq 0 (
    echo [错误] 提交失败，请检查 Git 状态。
    pause
    exit /b 1
)

echo.
echo [6/6] 推送到 GitHub main 分支
git remote set-url origin "%AUTH_REPO_URL%" >nul 2>&1
git push -u origin main
set "PUSH_RESULT=%errorlevel%"

git remote set-url origin "%REPO_URL%" >nul 2>&1

echo.
echo ========================================
if "%PUSH_RESULT%"=="0" (
    echo [成功] 已推送到 GitHub main 分支
    echo 提交说明：%COMMIT_MSG%
    echo 仓库地址：%REPO_URL%
    echo GitHub Actions 会自动开始构建 APK。
) else (
    echo [失败] 推送失败，请检查：
    echo   1. 网络是否正常
    echo   2. .git_token 是否有效
    echo   3. token 是否包含 repo + workflow 权限
    echo 远程地址已恢复为不带 token 的安全地址。
)
echo ========================================
echo.
pause
exit /b %PUSH_RESULT%

:safe_add
git add %~1 >nul 2>&1
exit /b 0
