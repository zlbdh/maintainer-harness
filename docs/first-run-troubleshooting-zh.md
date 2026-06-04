# First-run 中文排障

这份说明用于真实朋友、维护者、开发者跑 `run-review-demo.ps1`
时卡住后的快速排查。它不要求对方给好评，也不要求 star；失败反馈也可以直接贴到 issue #6。

## 先确认前提

- 需要能访问 GitHub。
- Windows 可以用系统自带 PowerShell。
- macOS 或 Linux 需要安装 PowerShell 7，并用 `pwsh` 运行脚本。
- 不需要私有仓库、生产凭据、API key 或客户日志。

## 从干净目录开始

如果本地目录状态不确定，建议重新 clone：

```powershell
git clone https://github.com/zlbdh/maintainer-harness.git
cd maintainer-harness
.\scripts\checks\run-review-demo.ps1
```

macOS 或 Linux：

```bash
git clone https://github.com/zlbdh/maintainer-harness.git
cd maintainer-harness
pwsh ./scripts/checks/run-review-demo.ps1
```

## 常见卡点

### 找不到 git

现象类似：

```text
git: The term 'git' is not recognized
```

处理方式：

- 先安装 Git。
- 重新打开终端。
- 再运行 `git --version` 确认能看到版本号。

### macOS 或 Linux 找不到 pwsh

现象类似：

```text
pwsh: command not found
```

处理方式：

- 安装 PowerShell 7。
- 重新打开终端。
- 再运行 `pwsh --version` 确认能看到版本号。

### Windows 不允许运行脚本

现象类似：

```text
running scripts is disabled on this system
```

可以只对这次命令放行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\checks\run-review-demo.ps1
```

如果使用 PowerShell 7：

```powershell
pwsh -ExecutionPolicy Bypass -File .\scripts\checks\run-review-demo.ps1
```

### Windows PowerShell 出现中文乱码或 ParserError

现象可能类似：

```text
Unexpected token '缁撴灉...' in expression or statement.
```

当前版本已经把含非 ASCII 文本的 PowerShell 源文件保存为 UTF-8 with BOM，
让 Windows PowerShell 5.1 能正确解析。如果你在较旧 checkout 里遇到这个问题：

- 先运行 `git pull`，再重新跑命令。
- 如果本地文件是从别处复制来的，建议重新 clone 一份干净仓库。
- 临时绕过方式是安装 PowerShell 7，然后运行
  `pwsh ./scripts/checks/run-review-demo.ps1`。

### 不在仓库根目录

现象通常是脚本路径找不到：

```text
The term '.\scripts\checks\run-review-demo.ps1' is not recognized
```

处理方式：

```powershell
cd maintainer-harness
Get-ChildItem .\scripts\checks\run-review-demo.ps1
.\scripts\checks\run-review-demo.ps1
```

macOS 或 Linux：

```bash
cd maintainer-harness
ls ./scripts/checks/run-review-demo.ps1
pwsh ./scripts/checks/run-review-demo.ps1
```

## 想少复制一步

可以让脚本复制 issue #6 的评论块：

```powershell
.\scripts\checks\run-review-demo.ps1 -CommentLanguage zh -CopyCommentToClipboard
```

也可以让脚本跑完后打开 issue #6 评论页：

```powershell
.\scripts\checks\run-review-demo.ps1 -CommentLanguage zh -CopyCommentToClipboard -OpenCommentTarget
```

macOS 或 Linux：

```bash
pwsh ./scripts/checks/run-review-demo.ps1 -CommentLanguage zh -CopyCommentToClipboard -OpenCommentTarget
```

`-OpenCommentTarget` 只会打开浏览器里的评论页，不会自动发布评论。请先检查生成内容，再决定是否粘贴提交。

## 失败也可以反馈

如果命令失败，仍然可以在 issue #6 留真实 first-run 反馈：

```text
https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new
```

推荐写清楚：

```text
我尝试运行 Maintainer Harness demo，但卡住了。
系统 / shell：[Windows PowerShell / macOS pwsh / Linux pwsh]
运行的命令：[粘贴命令]
错误信息：[粘贴最关键的 3-10 行]
我期望下一步文档说明：[一句话]
```

请不要贴 token、私有仓库地址、客户数据、生产日志或本机敏感路径。真实失败反馈比空泛好评更有价值。
