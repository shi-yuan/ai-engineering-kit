# CodeBuddy 项目入口

必须遵守聚合工作目录根目录的 `AGENTS.md`。

开始任务前：

1.  读取 `AGENTS.md`
2.  读取 `.agent-env.md`
3.  根据任务使用 `.agents/skills/` 中对应 Skill
4.  使用 `.agent-env.md` 中的 `OPEN_SPEC_ROOT`
5.  根据 `module-map.md` 搜索全部相关仓库

历史功能修改默认执行：

`brownfield-analysis → OpenSpec propose → design-review → 人工 Review → OpenSpec apply → verification → change-review`

CodeBuddy 的 Agent
能力用于提高执行效率，但不得替代共享分析、Design、Verification 和 Review
Artifact。
