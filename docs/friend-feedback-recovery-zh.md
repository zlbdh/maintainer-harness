# 朋友反馈回收说明

这份说明用于已经联系真实朋友、维护者或开发者之后：对方可能私聊回复、公开评论、跑 demo 失败，或者只给了一个模糊感受。目标是把真实反馈转成可改进项目、可公开复核的证据，同时避免把私聊、熟人帮忙、owner 行为误算成外部信号。

## 先判断反馈能不能计数

只有满足这些条件，才可能进入 `docs/external-feedback-evidence.yaml`：

- 对方是真实外部 reviewer，不是 owner、小号、受控账号、机器人或代发账号。
- 对方实际打开、阅读、检查示例或跑过 demo。
- 有公开 reviewer-visible URL，例如 issue `#5`/`#6` 的直接评论链接、公开 first-run 报告、或反馈驱动 follow-up issue。
- 链接能被第三方打开复核。
- 评论里没有 token、私有仓库地址、客户数据、生产日志或未授权截图。

私聊反馈不能冒充公开证据。下面这些不计数：

- 私聊截图。
- 只说“支持一下”“已 star”但没有看过项目。
- owner 自己的评论、自己的第二账号、受控组织账号。
- 没有直接 `#issuecomment-...` 锚点的普通 issue 页面。
- 你替朋友复制发布的评论。

## 如果朋友只私聊回复

先不要登记 evidence。可以这样回一句：

```text
谢谢，这条私聊反馈我会用来改项目，但它不能算公开外部证据。

如果你愿意公开留下一个很短的版本，可以按你真实看过/跑过的情况选一个：

只看文档或示例：
https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new

跑过 demo 或卡住了：
https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new

不用夸，写哪里不清楚、哪里跑不起来、还缺什么证据就行。你不想公开也完全可以。
```

如果对方不愿公开，尊重这个选择。私聊内容可以用来改文档或脚本，但不要写进公开 evidence 计数。

## 本地跟进 tracker

如果已经发给多位真实朋友或维护者，可以生成一个本地 ignored 的跟进表，只记录状态，不自动联系任何人，也不登记 evidence：

```powershell
.\scripts\checks\write-reviewer-followup-tracker.ps1
```

这个 tracker 用 `not-sent`、`sent`、`read`、`ran-demo`、`private-feedback`、`public-comment`、`feedback-follow-up`、`declined`、`no-response` 区分状态。只有对方自己发布了可复核的公开 URL 后，才进入候选扫描和证据验证；私聊反馈、owner 评论、小号或受控账号仍然不计数。

## 如果朋友公开评论了

1. 打开评论链接，确认是直接 issue comment URL，形如：

   ```text
   https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-...
   ```

2. 确认评论内容来自真实检查或真实 first-run。
3. 确认作者不是 owner、bot、小号或受控账号。
4. 确认没有敏感信息。
5. 先扫描候选：

   ```powershell
   .\scripts\checks\find-external-feedback-candidates.ps1 -AllowHtmlFallback
   .\scripts\checks\write-external-feedback-review-queue.ps1 -AllowHtmlFallback
   ```

6. 如果候选真实有效，再用 pending 或 verified 登记。没有完全确认前用 `pending`：

   ```powershell
   .\scripts\checks\add-external-feedback-evidence.ps1 -Id 2026-06-04-example -Type issue-comment -Status pending -Url https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-example -Summary "Outside reviewer gave concrete reviewability feedback."
   ```

7. 登记后验证：

   ```powershell
   .\scripts\checks\validate-external-feedback-evidence.ps1
   ```

## 如果反馈暴露了具体改进

如果公开反馈指出一个具体问题，例如命令不清楚、Codespaces 卡住、证据不足、安全边界不明确，就把它转成公开 follow-up：

```text
https://github.com/zlbdh/maintainer-harness/issues/new?template=feedback_follow_up.md
```

follow-up 要包含：

- 外部反馈源 URL。
- 具体 concern。
- 计划改什么。
- 完成后对应 commit、release note 或文档链接。

只有当 follow-up 本身公开、链接了真实外部反馈源，并且后续有可复核改动时，才可能作为 `feedback-follow-up` 信号。

## 如果朋友 star 了

不要追问“能不能再评论一下”来交换 star。可以只确认一件事：这个 star 是否来自真实阅读或试用。真实 star 是发现信号；评论和 first-run 报告通常更有用。

不要要求对方用第二账号 star。Self-owned alternate accounts do not count as external validation.

## 回收后的本地检查

每次有新公开反馈后，按这个顺序跑：

```powershell
.\scripts\checks\find-external-feedback-candidates.ps1 -AllowHtmlFallback
.\scripts\checks\validate-external-feedback-evidence.ps1
.\scripts\checks\measure-application-readiness.ps1 -PassThru
.\scripts\checks\check-public-ready.ps1 -PassThru
.\scripts\checks\check-public-evidence-links.ps1 -PassThru
.\scripts\checks\check-security-posture.ps1 -PassThru
```

如果本地匿名 GitHub API 限流，不要把 fallback 当 ready。等 reset、使用 token-backed readiness monitor，或用 `GITHUB_TOKEN`/`GH_TOKEN` 重新跑。

## 最小回收标准

在通知填写 OpenAI 表单前，至少要看到：

- 5 个真实 inspection 后的 stars。
- 2 条公开外部 maintainer feedback 或 first-run comments。
- 1 个外部 first-run report。
- 1 个反馈驱动 public follow-up issue、commit、release note 或文档改动。
- 最新 main CI、Pages、Codex readiness monitor 成功。

没有这些，就继续收集真实反馈，不要催表单，也不要制造互动。
