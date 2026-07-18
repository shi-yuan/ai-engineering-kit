# Agent Handoff 规范

## 目的

本文用于 Claude Code、CodeBuddy、Codex 等不同 Agent 或同一 Agent 不同会话之间交接复杂变更上下文，减少上下文丢失、重复分析和错误续写。

每个 Agent 在完成阶段性工作、暂停、切换工具、遇到阻塞、准备进入下一 Gate 前，都应留下 handoff。

## Handoff 模板

```markdown
# Agent Handoff: <change-id 或任务名>

## 当前目标

- 

## 当前 Gate

- Gate：
- 是否通过：
- 未通过原因：

## 已读上下文

- AGENTS.md：
- .agent-env.md：
- openspec/config.yaml：
- project-rules：
- rules：
- project-context：
- change artifacts：
- 业务代码：

## 已确认事实

### 业务

- 

### 代码

- 

### 数据库

- 

### 分布式链路

- RPC：
- MQ：
- Job：
- Redis/Cache：
- 配置：

## 合理推断

- 

## 待确认问题

| 问题 | 影响 | 建议确认对象 |
|---|---|---|
| | | |

## 当前设计边界

- 本次纳入：
- 本次不纳入：
- 禁止擅自改变：

## 已修改文件

| 文件 | 修改内容 | 原因 |
|---|---|---|
| | | |

## 已阅读但未修改的关键文件

| 文件 | 结论 |
|---|---|
| | |

## 已执行命令和验证

| 命令/验证 | 结果 | 备注 |
|---|---|---|
| | | |

## 未执行验证

| 验证项 | 未执行原因 | 剩余风险 |
|---|---|---|
| | | |

## 冲突或 Context Drift

- 

## 下一步建议

1. 
2. 
3. 
```

## 必填要求

Handoff 必须至少包含：

- 当前目标。
- 当前 Gate。
- 已确认事实。
- 待确认问题。
- 已修改文件。
- 已执行验证和未执行验证。
- 下一步建议。

不得只写“已完成”“继续实现”这类无法接续的信息。

## 交接规则

接手 Agent 必须先读取最近 handoff，再读取 change artifacts 和相关 project-context。若 handoff 与真实代码冲突，必须记录 Context Drift，并以真实代码分析当前行为。

如果 handoff 中存在阻塞待确认问题，接手 Agent 不得绕过该问题扩大实现范围；只能继续补证据、缩小范围或请求人工确认。

## 适用时机

必须写 handoff 的情况：

- 从 analysis 进入 proposal 前。
- 从 design 进入 apply 前。
- 实现过程中发现代码事实与设计冲突。
- 工具切换或 Agent 切换。
- 长时间任务被中断。
- 验证无法执行。
- 完成变更进入 review/context-sync 前。
