# AI Engineering Metrics

## 交付效率

| 指标 | 定义 | 记录方式 | 当前值 | 目标 |
|---|---|---|---|---|
| 一次通过率 | 首次通过 design-review / change-review / 人工 Code Review 的比例 | 每个 change 记录 PASS/BLOCKED | | |
| 返工次数 | 每个 change 从后续 Gate 返回前序 Gate 的次数 | workflow-state 或人工记录 | | |

## 质量与风险

| 指标 | 定义 | 记录方式 | 当前值 | 目标 |
|---|---|---|---|---|
| 漏改数 | change-review 或线上发现的遗漏仓库/模块/链路数量 | change-review 问题 | | |
| 超范围修改数 | 未在 design/tasks 声明但出现在 diff 的修改数量 | diff-summary | | |
| Context Drift 数 | 文档与真实代码冲突的数量 | context-sync-report | | |
| 线上缺陷逃逸率 | 通过 Gate 后仍进入线上缺陷的比例 | 事故/缺陷系统回填 | | |

## 使用规则

- 每个 C 类高风险变更必须记录上述指标。
- B 类历史功能增强建议记录。
- 指标只用于改进流程，不用于鼓励跳过 Gate。
