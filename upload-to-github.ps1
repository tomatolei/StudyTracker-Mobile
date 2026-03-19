$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $repo

$repoUrl = 'https://github.com/tomatolei/StudyTracker-Mobile.git'
$tokenFile = Join-Path $repo '.git_token'
$configFile = Join-Path $repo 'config.xml'
$defaultMsg = '项目更新'

function Pause-AndExit([int]$code = 0) {
    Write-Host ''
    cmd /c pause | Out-Host
    exit $code
}

Write-Host '========================================'
Write-Host '  StudyTracker-Mobile 一键提交到 GitHub'
Write-Host '========================================'
Write-Host ''

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host '[错误] 未检测到 Git，请先安装 Git。' -ForegroundColor Red
    Pause-AndExit 1
}

if (-not (Test-Path $tokenFile)) {
    Write-Host '[错误] 未找到 .git_token 文件。' -ForegroundColor Red
    Write-Host '请先在项目根目录创建 .git_token，并填入 GitHub PAT（需 repo + workflow 权限）。'
    Pause-AndExit 1
}

$token = (Get-Content $tokenFile -Raw).Trim()
if ([string]::IsNullOrWhiteSpace($token)) {
    Write-Host '[错误] .git_token 为空，请检查内容。' -ForegroundColor Red
    Pause-AndExit 1
}

Write-Host '[信息] 已读取 GitHub Token'

$appVersion = 'unknown'
if (Test-Path $configFile) {
    try {
        [xml]$xml = Get-Content $configFile -Raw
        if ($xml.widget.version) {
            $appVersion = [string]$xml.widget.version
        }
    } catch {
        $appVersion = 'unknown'
    }
}

if ($appVersion -eq 'unknown') {
    Write-Host '[提示] 未能自动识别版本号，将使用默认提交格式。' -ForegroundColor Yellow
} else {
    Write-Host "[信息] 当前版本号：v$appVersion"
}

Write-Host ''
$updateNote = Read-Host '请输入本次更新内容（例如：修复Excel导出和本地保存）'
if ([string]::IsNullOrWhiteSpace($updateNote)) {
    $updateNote = $defaultMsg
}

if ($appVersion -eq 'unknown') {
    $commitMsg = "update: $updateNote"
} else {
    $commitMsg = "update: v$appVersion $updateNote"
}

$authRepoUrl = "https://$token@github.com/tomatolei/StudyTracker-Mobile.git"

Write-Host ''
Write-Host '[1/6] 初始化 Git 仓库（如有需要）'
git init | Out-Null

Write-Host '[2/6] 切换到 main 分支'
git branch -M main | Out-Null

Write-Host '[3/6] 重置远程地址为安全模式'
try { git remote remove origin | Out-Null } catch {}
git remote add origin $repoUrl | Out-Null

Write-Host '[4/6] 暂存需要提交的主项目源码'
$pathsToAdd = @(
    '.github/workflows/android-build.yml',
    'README.md',
    'config.xml',
    'help-doc.html',
    'package.json',
    'package-lock.json',
    'upload-to-github.bat',
    'upload-to-github.ps1',
    'www',
    '更新日志-本次修复.md'
)
foreach ($path in $pathsToAdd) {
    if (Test-Path $path) {
        git add -- $path
    }
}

$trackedKeystore = git ls-files studytracker.keystore 2>$null
if ($trackedKeystore) {
    git rm --cached studytracker.keystore | Out-Null
}

Write-Host ''
Write-Host '本次准备提交的源码变更：'
git diff --cached --name-status

git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host ''
    Write-Host '[提示] 当前没有新的主项目源码变更可提交。' -ForegroundColor Yellow
    Write-Host '说明：'
    Write-Host '  - Android Studio 产物目录不会被提交'
    Write-Host '  - build.ps1 这类本地脚本不会被提交'
    Write-Host '  - 如果你刚改的是源码，请确认已保存在主项目目录中'
    Pause-AndExit 0
}

Write-Host ''
Write-Host '[5/6] 提交代码'
git commit -m $commitMsg
if ($LASTEXITCODE -ne 0) {
    Write-Host '[错误] 提交失败，请检查 Git 状态。' -ForegroundColor Red
    Pause-AndExit 1
}

Write-Host ''
Write-Host '[6/6] 推送到 GitHub main 分支'
git remote set-url origin $authRepoUrl | Out-Null
git push -u origin main
$pushResult = $LASTEXITCODE
git remote set-url origin $repoUrl | Out-Null

Write-Host ''
Write-Host '========================================'
if ($pushResult -eq 0) {
    Write-Host '[成功] 已推送到 GitHub main 分支' -ForegroundColor Green
    Write-Host "提交说明：$commitMsg"
    Write-Host "仓库地址：$repoUrl"
    Write-Host 'GitHub Actions 会自动开始构建 APK。'
} else {
    Write-Host '[失败] 推送失败，请检查：' -ForegroundColor Red
    Write-Host '  1. 网络是否正常'
    Write-Host '  2. .git_token 是否有效'
    Write-Host '  3. token 是否包含 repo + workflow 权限'
    Write-Host '远程地址已恢复为不带 token 的安全地址。'
}
Write-Host '========================================'

Pause-AndExit $pushResult
