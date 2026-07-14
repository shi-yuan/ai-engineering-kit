# Claude Code 项目入口

必须遵守聚合工作目录根目录的 `AGENTS.md`。

开始任务前：

1.  读取 `AGENTS.md`
2.  读取 `.agent-env.md`
3.  根据任务使用 `.agents/skills/` 中对应 Skill
4.  使用 `.agent-env.md` 中的 `OPEN_SPEC_ROOT`
5.  根据 `module-map.md` 检查全部相关仓库

历史功能修改默认执行：

`brownfield-analysis → OpenSpec propose → design-review → 人工 Review → OpenSpec apply → verification → change-review`

Claude Code 的 Plan、Explore、Subagent
等能力可以用于提高调查和执行效率，但不得替代共享 Artifact。

当使用 Subagent 并行调查时，主 Agent 必须负责：

-   合并证据
-   消除结论冲突
-   区分事实与假设
-   形成最终 Change Analysis 或 Review Artifact
