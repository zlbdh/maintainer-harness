# 给真实朋友和维护者的实测说明

这份说明用于发给真实朋友、维护者、开发者，让他们先实际打开、阅读或运行，再自行决定是否评论或 star。

请不要让对方为了帮忙而直接点赞。请不要交换 star、购买互动、使用机器人、群发拉票，或让没有看过项目的人评论。Self-owned alternate accounts do not count as external validation.

## 你自己的发送步骤

1. 选 3 到 5 个真实认识的人，最好是维护过仓库、写过 CI、用过 coding agent、做过 devtools 或能看懂开源项目的人。
2. 单独私信，不要群发刷屏。把下面的「可以直接发的消息」发给对方。
3. 明确说“不需要为了帮忙 star”。请对方先看项目页、读文档或跑 demo，再决定是否评论或 star。
4. 如果对方只愿意看 3 分钟，请让他去 issue #5 留一个具体 reviewability 反馈。
5. 如果对方愿意跑 5 到 10 分钟，请让他按 demo 步骤跑一次，并把生成的 first-run block 贴到 issue #6。
6. 如果对方只私下回复你，也可以用于改进项目，但不要把它当成公开外部证据计数。
7. 如果对方公开留下了评论、first-run 报告或反馈驱动 follow-up，把公开链接发回来，后续再登记到 `docs/external-feedback-evidence.yaml`。

最重要的是：不要催 star，不要暗示“帮我点一下就行”。要问“哪里不清楚、哪里不可信、哪里跑不起来”。

## 可以直接发的消息

```text
我在准备 Maintainer Harness 的 OpenAI Codex for OSS 申请，想请你做一个真实外部试用或短评。

项目是一个开源维护者工具，用来把 Codex/agent 的工作变成可审查的 change brief、impact map、任务卡、验证证据和发布记录。项目还很早，demo 用的是合成样例，不需要私有仓库或生产凭据。

请你不要为了帮忙直接 star。更希望你先打开页面、看一眼文档，或者跑一下 demo；如果你觉得有价值，再按真实感受评论或 star。

项目页：
https://zlbdh.github.io/maintainer-harness/

最快评论入口：
https://zlbdh.github.io/maintainer-harness/external-review.html#templates

如果只看文档，请在 issue #5 留一句具体反馈：
https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new

如果愿意跑 demo，请把生成的 first-run block 贴到 issue #6：
https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new
```

## 30 秒短版

```text
能不能帮我真实看一下这个开源项目？不是让你直接 star。

项目页：
https://zlbdh.github.io/maintainer-harness/

如果只看文档，麻烦在 issue #5 留一句具体反馈：什么证据会让你愿意接受 agent 的输出？
https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new

如果愿意跑 demo，按页面里的命令跑完，把生成的 first-run block 贴到 issue #6：
https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new

你觉得有价值再 star；没价值、不清楚、跑失败，都请直接说，失败反馈更有用。
```

## 朋友实际操作步骤

### 1. 先打开项目

打开项目页：

```text
https://zlbdh.github.io/maintainer-harness/
```

看三件事就够了：

- 这个工具是不是能让 agent 输出更容易审查
- demo 命令是否清楚
- 你作为维护者还缺什么证据才敢接受 agent 的工作

### 2. 不跑代码也可以反馈

如果只是看文档或示例，请打开 issue #5：

```text
https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new
```

可以贴这个模板：

```text
我作为外部读者看了 Maintainer Harness。
我的身份/视角：[维护者 / 开发者 / devtools builder / 其他]

在接受 agent 输出前，我还需要看到的证据是：
- [写一个具体点，例如测试命令、失败处理、改动范围、发布证据等]

最不清楚的地方：
- [一句话]

我会不会在真实仓库尝试：[会 / 不会 / 可能会]，原因是：[一句话]
```

### 3. 愿意跑 demo 的步骤

Windows PowerShell：

```powershell
git clone https://github.com/zlbdh/maintainer-harness.git
cd maintainer-harness
.\scripts\checks\run-review-demo.ps1
```

如果想少一步复制，可以运行：

```powershell
.\scripts\checks\run-review-demo.ps1 -CopyCommentToClipboard
```

如果还想让脚本跑完后打开 issue #6 评论入口，可以运行：

```powershell
.\scripts\checks\run-review-demo.ps1 -CopyCommentToClipboard -OpenCommentTarget
```

这个开关只会打开浏览器里的 issue #6 评论页，不会自动发布评论。请先检查剪贴板里的内容，再决定是否粘贴提交。

macOS 或 Linux，需要先装 PowerShell 7，然后运行：

```bash
git clone https://github.com/zlbdh/maintainer-harness.git
cd maintainer-harness
pwsh ./scripts/checks/run-review-demo.ps1
```

也可以运行：

```bash
pwsh ./scripts/checks/run-review-demo.ps1 -CopyCommentToClipboard
```

如果还想打开 issue #6 评论入口：

```bash
pwsh ./scripts/checks/run-review-demo.ps1 -CopyCommentToClipboard -OpenCommentTarget
```

这个开关只会打开浏览器里的 issue #6 评论页，不会自动发布评论。请先检查生成内容，再决定是否粘贴提交。

跑完后，脚本会生成一个本地报告，里面有 `Copy This Comment Into Issue #6`。请复制那段，贴到 issue #6：

```text
https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new
```

如果命令失败，也可以照样反馈失败点。失败报告比空泛夸奖更有用。

如果卡在 Git、PowerShell、执行策略、路径或复制评论块，可以先看中文排障：

```text
https://github.com/zlbdh/maintainer-harness/blob/main/docs/first-run-troubleshooting-zh.md
```

### 4. star 的规则

可以 star，但前提是你真的打开、看过或跑过，并且觉得这个工作流值得推荐给其他维护者。

不需要为了帮忙 star。评论、失败反馈、改进建议通常比 star 更有价值。

### 5. 什么反馈最有用

最有用的是具体句子，例如：

- 哪一步看不懂
- 哪个命令跑不起来
- 哪个证据还不足以让你接受 agent 输出
- 哪个安全边界让你放心或不放心
- 如果你要在真实仓库里用，还缺什么

### 6. 不要这样做

- 不要用小号、第二账号、受控组织账号来评论或 star
- 不要互换 star
- 不要付费买 star 或评论
- 不要让没看过项目的人评论
- 不要复制模板后不改就发

这次需要的是真实外部看过、试过、想过之后的反馈。
