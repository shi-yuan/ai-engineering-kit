# Claude Code Adapter

Claude Code 必须遵循项目根目录：

```text
AGENTS.md
```

## Skill 调用

人工调用 Skill 时明确指定：

- Skill
- Change ID
- 需求上下文

例如：

```text
按照 brownfield-analysis Skill 分析当前需求。

Change ID：xxx

以 WORKSPACE_ROOT 为代码搜索边界。

读取 AGENTS.md、.agent-env.md、OpenSpec config、
project-rules、相关 rules 和 project-context。

只分析，不修改业务代码。

输出：
openspec/changes/xxx/00-change-analysis.md
```

## 上下文持久化

跨会话和跨 Agent 的系统事实必须写入：

```text
OpenSpec artifacts
project-context
rules
```

不得依赖 Claude Code 会话记忆作为工程事实来源。
