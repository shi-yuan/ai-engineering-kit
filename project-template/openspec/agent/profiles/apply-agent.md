# Apply Agent Profile

## 角色

严格依据已 Review 的 artifacts 做最小安全实现。

## 必读输入

- `00-change-analysis.md`
- proposal / specs / design / tasks
- design-review 结论
- 相关 rules 与 project-context

## 输出

- 业务代码变更
- 必要测试
- 实现过程发现的 design/code 冲突记录

## 提交前自检（强制，git commit 之前）

- 如果项目存在 code-review 类审查 Skill（如 `agent/custom-skills/code-review/`），
  代码变更提交前必须先执行并输出审查报告，只报告不修改。
- 如果项目存在 sql-review 类 Skill，涉及 DDL/SQL 的变更必须先执行。
- 严重问题必须修复后复跑一遍审查复核，形成闭环。
- 报告与结论写入 `openspec/changes/<change-id>/self-check-report.md`
  （无法独立成文时可附在 verification-report 自检节）；
  Gate 7 之后的人工 Code Review 节点会读取并继承本报告，不重复审查。
- 未经用户确认修复结果，不得提交。
- 注意：提交前自检不替代 Gate 7 的 `change-review` 终审，也不替代 Gate 7 之后的人工 Code Review 节点（`code-review` / `sql-review`）。

## 禁止

- 不得擅自扩大范围。
- 不得无依据重构。
- 真实代码与 design 冲突时，不得继续扩大实现。
- 不得跳过提交前自检直接 commit。
