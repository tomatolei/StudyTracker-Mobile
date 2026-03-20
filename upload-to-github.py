from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path
import xml.etree.ElementTree as ET

REPO_URL = "https://github.com/tomatolei/StudyTracker-Mobile.git"
DEFAULT_MSG = "项目更新"
TRACKED_PATHS = [
    ".github/workflows/android-build.yml",
    "README.md",
    "config.xml",
    "help-doc.html",
    "package.json",
    "package-lock.json",
    "upload-to-github.bat",
    "upload-to-github.py",
    "www",
]


def run(cmd: list[str], cwd: Path, check: bool = True, capture: bool = False) -> subprocess.CompletedProcess:
    return subprocess.run(
        cmd,
        cwd=str(cwd),
        check=check,
        text=True,
        encoding="utf-8",
        errors="replace",
        capture_output=capture,
    )


def try_run(cmd: list[str], cwd: Path) -> subprocess.CompletedProcess:
    return subprocess.run(
        cmd,
        cwd=str(cwd),
        check=False,
        text=True,
        encoding="utf-8",
        errors="replace",
        capture_output=True,
    )


def read_version(config_file: Path) -> str:
    try:
        tree = ET.parse(config_file)
        root = tree.getroot()
        return root.attrib.get("version", "unknown")
    except Exception:
        return "unknown"


def pause_exit(code: int = 0) -> None:
    print()
    os.system("pause")
    raise SystemExit(code)


def main() -> int:
    repo = Path(__file__).resolve().parent
    os.chdir(repo)

    token_file = repo / ".git_token"
    config_file = repo / "config.xml"

    print("========================================")
    print("  StudyTracker-Mobile 一键提交到 GitHub（自动识别版本）")
    print("========================================")
    print()

    if try_run(["git", "--version"], repo).returncode != 0:
        print("[错误] 未检测到 Git，请先安装 Git。")
        pause_exit(1)

    if not token_file.exists():
        print("[错误] 未找到 .git_token 文件。")
        print("请先在项目根目录创建 .git_token，并填入 GitHub PAT（需 repo + workflow 权限）。")
        pause_exit(1)

    token = token_file.read_text(encoding="utf-8").strip()
    if not token:
        print("[错误] .git_token 为空，请检查内容。")
        pause_exit(1)

    print("[信息] 已读取 GitHub Token")

    app_version = read_version(config_file)
    if app_version == "unknown":
        print("[提示] 未能自动识别版本号，将使用默认提交格式。")
    else:
        print(f"[信息] 当前版本号：v{app_version}")

    print()
    update_note = input("请输入本次更新内容（例如：修复Excel导出和本地保存）: ").strip()
    if not update_note:
        update_note = DEFAULT_MSG

    commit_msg = f"update: v{app_version} {update_note}" if app_version != "unknown" else f"update: {update_note}"
    auth_repo_url = f"https://{token}@github.com/tomatolei/StudyTracker-Mobile.git"

    print()
    print("[1/6] 初始化 Git 仓库（如有需要）")
    try_run(["git", "init"], repo)

    print("[2/6] 切换到 main 分支")
    run(["git", "branch", "-M", "main"], repo)

    print("[3/6] 重置远程地址为安全模式")
    try_run(["git", "remote", "remove", "origin"], repo)
    run(["git", "remote", "add", "origin", REPO_URL], repo)

    print("[4/6] 暂存需要提交的主项目源码")
    for path in TRACKED_PATHS:
        if (repo / path).exists():
            run(["git", "add", "--", path], repo)

    tracked_keystore = try_run(["git", "ls-files", "studytracker.keystore"], repo)
    if tracked_keystore.stdout.strip():
        try_run(["git", "rm", "--cached", "studytracker.keystore"], repo)

    print()
    print("本次准备提交的源码变更：")
    diff_cached = try_run(["git", "diff", "--cached", "--name-status"], repo)
    print(diff_cached.stdout.strip() or "(无)")

    diff_quiet = try_run(["git", "diff", "--cached", "--quiet"], repo)
    if diff_quiet.returncode == 0:
        print()
        print("[提示] 当前没有新的主项目源码变更可提交。")
        print("说明：")
        print("  - Android Studio 产物目录不会被提交")
        print("  - build.ps1 这类本地脚本不会被提交")
        print("  - 如果你刚改的是源码，请确认已保存在主项目目录中")
        pause_exit(0)

    print()
    print("[5/6] 提交代码")
    commit_result = try_run(["git", "commit", "-m", commit_msg], repo)
    if commit_result.returncode != 0:
        print(commit_result.stdout)
        print(commit_result.stderr)
        print("[错误] 提交失败，请检查 Git 状态。")
        pause_exit(1)

    print()
    print("[6/6] 推送到 GitHub main 分支")
    run(["git", "remote", "set-url", "origin", auth_repo_url], repo)
    push_result = try_run(["git", "push", "-u", "origin", "main"], repo)
    run(["git", "remote", "set-url", "origin", REPO_URL], repo)

    print(push_result.stdout, end="")
    if push_result.stderr:
        print(push_result.stderr, end="")

    print()
    print("========================================")
    if push_result.returncode == 0:
        print("[成功] 已推送到 GitHub main 分支")
        print(f"提交说明：{commit_msg}")
        print(f"仓库地址：{REPO_URL}")
        print("GitHub Actions 会自动开始构建 APK。")
    else:
        print("[失败] 推送失败，请检查：")
        print("  1. 网络是否正常")
        print("  2. .git_token 是否有效")
        print("  3. token 是否包含 repo + workflow 权限")
        print("远程地址已恢复为不带 token 的安全地址。")
        pause_exit(push_result.returncode)

    pause_exit(0)
    return 0


if __name__ == "__main__":
    main()
