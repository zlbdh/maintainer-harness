# 朋友实测发送前检查清单

这份清单用于把 Maintainer Harness 发给真实朋友、维护者或开发者之前。目标是减少误会：不是求 star，不是互赞，也不是让别人替你写评论；而是让对方实际打开、阅读或运行后，按自己的真实体验决定是否公开反馈。

## 1. 先选对人

适合发送给这些人：

- 做过开源维护、代码审查、CI、发布或 devtools 的人。
- 用过 Codex、coding agent、CI agent 或自动化开发工具的人。
- 愿意花 3 到 10 分钟真实看项目或跑 demo 的朋友。
- 能判断“什么证据足够让我接受或拒绝 agent 输出”的开发者。

不要发送给这些人来凑数：

- 没时间打开项目，只能帮忙点 star 的人。
- 自己的小号、受控组织账号、机器人或代发账号。
- 只想互换 star、互相点赞或批量刷互动的人。

不要用小号、机器人、受控账号或代发账号制造外部信号。

Self-owned alternate accounts do not count as external validation.

## 2. 发送前确认三句话

发出去前，消息里必须保留这三层意思：

- 不是让你直接 star，也不是互赞。
- 请先实际打开、阅读或运行，再自行决定是否评论或 star。
- 跑失败、看不懂、不想 star 都可以直接说，具体失败反馈更有用。

如果消息里只剩“帮我点个 star”，就不要发。

## 3. 用一对一消息，不要群发

推荐一对一发送，并按收件人改一句上下文：

```text
能不能帮我真实看一下这个开源项目？不是让你直接 star，也不是互赞。

我想听你从 [维护者 / devtools / CI / 安全 / agent 使用者] 视角的一句具体反馈：
什么证据会让你更敢接受、拒绝或要求修改 agent 输出？

一页中文教程：
https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-review-onepager-zh.md

外部评审入口：
https://zlbdh.github.io/maintainer-harness/external-review.html#zh-review

你觉得有价值再 star；没价值、不清楚、跑失败，都请直接说。
```

不要群发“求支持”。如果要发给多人，也逐个确认对方确实可能看项目或跑 demo。

## 4. 邀请草稿发送前预检

如果你不确定文字有没有变成“求 star”“互赞”“没看也能评论”，先把准备发出的私信草稿保存到本地文件，再跑：

```powershell
.\scripts\checks\check-reviewer-invite-draft.ps1 -Path .\reports\reviewer-invite-draft.txt -Audience zh-friend -PassThru
```

也可以直接检查一小段文本：

```powershell
.\scripts\checks\check-reviewer-invite-draft.ps1 -Text "能不能帮我真实看一下这个开源项目？不是让你直接 star，也不是互赞。请先实际打开页面、看文档或跑 demo，再按真实感受决定是否评论或 star。" -Audience zh-friend -PassThru
```

这个预检只检查草稿，不会联系任何人、不会发消息、不会发评论、不会创建 star，也不会登记 evidence。它会拦截直接求 star、互换/购买互动、小号或受控账号、没看也能评论、替朋友写好评论让对方复制等风险文案。

## 5. 给对方三个路径

只看 3 分钟文档：

```text
https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new
```

用 Codespaces 跑 10 分钟 demo：

```text
https://codespaces.new/zlbdh/maintainer-harness?quickstart=1
```

跑完后把 first-run 反馈贴到 issue #6：

```text
https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new
```

本地跑 10 分钟 demo：

```powershell
git clone https://github.com/zlbdh/maintainer-harness.git
cd maintainer-harness
.\scripts\checks\run-review-demo.ps1 -CommentLanguage zh -CopyCommentToClipboard -OpenCommentTarget
```

macOS 或 Linux：

```bash
git clone https://github.com/zlbdh/maintainer-harness.git
cd maintainer-harness
pwsh ./scripts/checks/run-review-demo.ps1 -CommentLanguage zh -CopyCommentToClipboard -OpenCommentTarget
```

提醒对方：脚本不会自动发布评论、创建 star 或登记 evidence。

## 6. 发完以后只记录状态，不替人发评论

可以在本地记录这些状态：

- sent: 已一对一发出。
- read: 对方说已经打开或看过。
- ran-demo: 对方跑过 demo。
- private-feedback: 对方只私聊反馈。
- public-comment: 对方自己发布了公开评论。
- no-response: 暂无回复。

不要替朋友复制评论到 issue。只有对方自己发布、第三方能打开复核的公开链接，才可能进入证据登记。

## 7. 回收公开链接

如果对方公开评论，请让对方把直接评论链接发回，形如：

```text
https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-...
```

或：

```text
https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-...
```

然后按反馈回收说明处理：

```text
https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-feedback-recovery-zh.md
```

如果只是私聊截图、口头反馈、普通 issue 页面、owner 自己评论、小号评论，都不要登记成 verified evidence。

## 8. 发送后复测

每次出现新的公开反馈后，先扫描候选，再验证 evidence：

```powershell
.\scripts\checks\find-external-feedback-candidates.ps1 -AllowHtmlFallback
.\scripts\checks\write-external-feedback-review-queue.ps1 -AllowHtmlFallback
.\scripts\checks\validate-external-feedback-evidence.ps1
```

如果本地匿名 GitHub API 限流，不要把 fallback 当 ready。等 reset、使用 token-backed readiness monitor，或带 `GITHUB_TOKEN`/`GH_TOKEN` 重新跑 readiness。

## 9. 什么时候可以通知填表

只有这些硬门槛都满足后，才通知填写 OpenAI 表单：

- 至少 5 个真实 inspection 后的 stars。
- 至少 2 条公开 maintainer feedback 或 first-run comments。
- 至少 1 个外部 first-run report。
- 至少 1 个反馈驱动 public follow-up issue、commit、release note 或文档改动。
- 最新 main CI、Pages、Codex readiness monitor 成功。

没有达到这些条件，就继续真实外部验证，不要制造互动。
