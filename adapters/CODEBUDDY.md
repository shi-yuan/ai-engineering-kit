# CodeBuddy Adapter

CodeBuddy 必须遵循项目根目录：

```text
AGENTS.md
```

## Skill 调用

人工调用 Skill 时：

1. 指定对应 `SKILL.md`。
2. 指定 Change ID。
3. 指定需求上下文。
4. 指定输出位置。

历史功能变更优先执行：

```text
brownfield-analysis
```

## Workspace

必须搜索整个：

```text
WORKSPACE_ROOT
```

不得因为 OpenSpec 是独立仓库，只分析 OpenSpec 仓库。

## Agent 切换

跨 Agent 切换时，以：

```text
OpenSpec artifacts
```

作为事实交接载体。

不得依赖 CodeBuddy 私有上下文。
