# Maintainer Harness 朋友实测一页教程

这是一份可以直接发给真实朋友、维护者或开发者的一页教程。目标不是让对方帮忙刷 star，而是请对方真实打开、阅读或运行后，留下可公开复核的具体反馈。

请先说清楚三句话：

- 不需要为了帮忙 star。
- 看不懂、跑失败、不想 star 都可以直接说。
- 只有真实看过或跑过后的公开评论，才适合作为外部反馈证据。

项目入口：

```text
https://zlbdh.github.io/maintainer-harness/external-review.html
```

GitHub 仓库：

```text
https://github.com/zlbdh/maintainer-harness
```

维护者发送前检查清单：

```text
https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-review-send-checklist-zh.md
```

## 可以直接发给朋友的消息

```text
能不能帮我真实看一下这个开源项目？不是让你直接 star，也不是互赞。

项目叫 Maintainer Harness，是给开源维护者用的 agent 工作审查工具：把 Codex/agent 的工作变成 change brief、impact map、任务卡、验证证据和发布记录。

请你任选一个路径：

1. 只看 3 分钟文档，然后在 issue #5 留一句具体反馈：
   https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new

2. 不想安装东西，就用 Codespaces 跑 10 分钟 demo，然后在 issue #6 留 first-run 反馈：
   https://codespaces.new/zlbdh/maintainer-harness?quickstart=1

3. 愿意本地跑，就 clone 后执行 demo，再把生成的评论块贴到 issue #6：
   https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new

入口页：
https://zlbdh.github.io/maintainer-harness/external-review.html

你觉得有价值再 star；没价值、不清楚、跑失败，都请直接说。失败反馈比空泛夸奖更有用。
```

## 路径 A：只看 3 分钟文档

适合不想跑代码、但能判断维护者工作流是否可信的人。

1. 打开外部评审入口：

   ```text
   https://zlbdh.github.io/maintainer-harness/external-review.html
   ```

2. 看三件事：

   - 这个工具想解决什么维护者问题。
   - agent 输出里有哪些证据可以审查。
   - 你还缺什么证据才敢接受 agent 的工作。

3. 打开 issue #5：

   ```text
   https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new
   ```

4. 粘贴并改写这个模板：

   ```text
   我作为外部读者看了 Maintainer Harness。
   我的身份/视角：[维护者 / 开发者 / devtools builder / 其他]

   在接受 agent 输出前，我还需要看到的证据是：
   - [写一个具体点，例如测试命令、失败处理、改动范围、发布证据等]

   最不清楚的地方：
   - [一句话]

   我会不会在真实仓库尝试：[会 / 不会 / 可能会]，原因是：[一句话]
   ```

## 路径 B：用 Codespaces 跑 10 分钟 demo

适合没有本地 Git、PowerShell，或只想最快从云端跑一次的人。

1. 打开 Codespaces：

   ```text
   https://codespaces.new/zlbdh/maintainer-harness?quickstart=1
   ```

2. 等网页终端打开后运行：

   ```bash
   pwsh ./scripts/checks/run-review-demo.ps1 -CommentLanguage zh -CopyCommentToClipboard -OpenCommentTarget
   ```

3. 命令会做三件事：

   - 运行合成 demo 检查。
   - 生成本地 first-run 报告。
   - 复制中文 issue #6 评论块，并打开 issue #6 评论页。

4. 它不会做三件事：

   - 不会自动发布评论。
   - 不会创建 star。
   - 不会登记 evidence。

5. 请先检查剪贴板里的内容，再决定是否粘贴到 issue #6：

   ```text
   https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new
   ```

如果命令失败，也请把失败点写出来。失败反馈能帮助修正文档或脚本。

## 路径 C：本地跑 10 分钟 demo

Windows PowerShell：

```powershell
git clone https://github.com/zlbdh/maintainer-harness.git
cd maintainer-harness
.\scripts\checks\run-review-demo.ps1 -CommentLanguage zh -CopyCommentToClipboard -OpenCommentTarget
```

macOS 或 Linux 需要 PowerShell 7：

```bash
git clone https://github.com/zlbdh/maintainer-harness.git
cd maintainer-harness
pwsh ./scripts/checks/run-review-demo.ps1 -CommentLanguage zh -CopyCommentToClipboard -OpenCommentTarget
```

跑完后，把生成的 issue #6 评论块贴到：

```text
https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new
```

如果卡在 Git、PowerShell、执行策略、路径或复制评论块，可以先看中文排障：

```text
https://github.com/zlbdh/maintainer-harness/blob/main/docs/first-run-troubleshooting-zh.md
```

## star 规则

可以 star，但前提是你真的打开、看过或跑过，并且觉得这个工作流值得推荐给其他维护者。

不需要为了帮忙 star。不要互换 star，不要付费买互动，不要用小号或自己控制的账号评论或 star。

Self-owned alternate accounts do not count as external validation.

## 什么反馈最有用

最有用的是具体句子：

- 哪一步看不懂。
- 哪个命令跑不起来。
- 哪个证据还不足以让你接受 agent 输出。
- 哪个安全边界让你放心或不放心。
- 如果要在真实仓库里用，还缺什么。

私聊反馈可以用来改进项目，但不计入公开外部证据。公开 issue 评论、first-run 报告、反馈驱动 issue 或 commit 才方便复核。
