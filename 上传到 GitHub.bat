@echo off
chcp 65001 >nul
echo ========================================
echo   学习监督 APP - 一键上传到 GitHub
echo ========================================
echo.

REM 检查 git 是否安装
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ? 错误：未检测到 Git，请先安装 Git
    echo 下载地址：https://git-scm.com/
    pause
    exit /b 1
)

echo ? Git 已安装
echo.

REM 初始化 git 仓库（如果已初始化会提示，忽略）
echo [1/5] 初始化 Git 仓库...
git init >nul 2>&1

REM 添加所有文件
echo [2/5] 添加文件...
git add .

REM 提交
echo [3/5] 提交更改...
git commit -m "学习监督 APP - 更新源码"

REM 确保分支是 master
echo [4/5] 设置分支...
git branch -M master >nul 2>&1

REM 关联远程仓库（如果已关联会提示，忽略）
git remote set-url origin https://github.com/tomatolei/StudyTracker-Mobile.git >nul 2>&1
if %errorlevel% neq 0 (
    git remote add origin https://github.com/tomatolei/StudyTracker-Mobile.git >nul 2>&1
)

REM 强制推送到 GitHub
echo [5/5] 推送到 GitHub...
echo.
echo ??  即将强制覆盖 GitHub 上的所有文件...
echo.
git push -f origin master

echo.
echo ========================================
if %errorlevel% equ 0 (
    echo ? 上传成功！
    echo.
    echo ?? 查看仓库：https://github.com/tomatolei/StudyTracker-Mobile
) else (
    echo ? 上传失败，请检查网络连接或 GitHub 账号
    echo.
    echo ?? 可能需要 GitHub 验证：
    echo    1. 打开 https://github.com/settings/tokens
    echo    2. 生成新的 Personal Access Token
    echo    3. 使用 Token 代替密码
)
echo ========================================
echo.
pause
