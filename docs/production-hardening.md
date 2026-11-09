# 生产化升级指南

本文记录 AI Engineering Kit 从人工 Gate 试点升级到生产化落地时必须补齐的能力。

## 1. 上下文健康治理

目标：避免 `AGENTS.md`、项目规则和长期上下文无限膨胀，降低 Agent 遵循冲突规则的概率。

项目必须维护：

- `openspec/rules/context-health.md`
- `openspec/project-context/module-map.md`
- `openspec/project-context/data-state-registry.md`
- `openspec/project-context/business/business-invariants.md`
- `openspec/project-context/integration/*-registry.md`

执行原则：

- L0/L1 必读，L2/L3 按需加载，L4 历史参考默认不加载。
- 长期事实必须带证据链接。
- Path-specific 规则通过模块地图、业务不变量和集成 registry 定位。
- 文档与真实代码冲突时记录 Context Drift。

## 2. 安全接入与 Skill 分层

`setup-agent` 刷新公共 Skill 前会备份：

```text
openspec/agent/skills.backup/<timestamp>/
```

Skill 分层：

| 位置 | 用途 | 是否会被 setup-agent 覆盖 |
|---|---|---|
| `openspec/agent/custom-skills/` | 项目自定义 Skill | 否 |
| `openspec/agent/skills/` | Kit 公共 Skill 快照 | 是，刷新前备份 |
| `AI_ENGINEERING_KIT_HOME/skills/` | Kit 源 Skill | 否 |

## 3. Gate 最低校验

Kit 提供：

```powershell
scripts/check-change.ps1 -ChangeId <change-id> -NextGate apply
```

用于检查进入下一 Gate 前是否具备最低 artifact 条件，包括：

- `00-change-analysis.md`
- proposal / specs
- design / tasks
- design-review 结论
- verification-report
- change-review
- context-sync-report

该脚本不是人工 Review 的替代，而是防止明显缺失材料进入下一阶段。

## 4. 多仓 Diff Summary

Kit 提供：

```powershell
scripts/change-diff-summary.ps1 -ChangeId <change-id> -ProjectRoot <workspace-root>
```

输出：

```text
openspec/changes/<change-id>/diff-summary.md
```

用途：

- 汇总多仓实际 diff。
- 提取 design/tasks 中声明的文件路径。
- 标记 diff 中未声明文件，辅助识别超范围修改。
- 标记声明但未修改文件，辅助识别遗漏实现或陈旧设计。

## 5. Kit 自检

Kit 提供：

```powershell
scripts/lint-kit.ps1
```

检查：

- Kit 版本一致性。
- Skill manifest entry 是否存在。
- 必需模板是否存在。
- 关键模板是否包含必填章节。
- 是否残留旧版本号。

## 6. Agent 角色 Profile

项目模板提供：

```text
openspec/agent/profiles/analysis-agent.md
openspec/agent/profiles/design-agent.md
openspec/agent/profiles/apply-agent.md
openspec/agent/profiles/review-agent.md
openspec/agent/profiles/verification-agent.md
```

建议：

- 写 design 的 Agent 不做 design-review。
- 写代码的 Agent 不做 change-review。
- Review Agent 必须基于真实 diff 和证据，而不是实现 Agent 的描述。

## 7. 度量体系

项目模板提供：

```text
openspec/project-context/metrics/ai-engineering-metrics.md
```

建议持续记录：

- 一次通过率。
- 返工次数。
- 漏改数。
- 超范围修改数。
- Context Drift 数。
- 线上缺陷逃逸率。

这些指标用于改进流程，不用于鼓励跳过 Gate。
