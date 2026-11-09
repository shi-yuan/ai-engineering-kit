# 默认变更流程

## 需求分类

| 类型 | 判断标准 | 推荐流程 |
|---|---|---|
| A 全新独立功能 | 与历史接口、历史状态、历史数据、异步链路基本无耦合 | 可简化 brownfield-analysis，但仍需 Proposal、Design、Tasks、Verification |
| B 历史功能增强 | 修改既有接口、流程、表、状态、消息、任务、兼容逻辑 | 必须完整执行 Gate 0-8 |
| C 高风险核心变更 | 涉及资金、库存、授信、合同、权限、计费、清结算、履约等 | 完整 Gate + 人工关键事实确认 + 架构/业务 Review + 上线风险清单 |

## Gate 0：Context Loading

执行任何阶段前必须读取：

- `AGENTS.md`
- `.agent-env.md`
- `OPEN_SPEC_ROOT/config.yaml`
- `OPEN_SPEC_ROOT/agent/project-rules.md`
- 相关 `OPEN_SPEC_ROOT/rules/*.md`
- 相关 `OPEN_SPEC_ROOT/project-context/*.md`
- 当前 change artifacts
- Workspace 中相关业务代码

通过条件：

```text
确认 WORKSPACE_ROOT、OPEN_SPEC_ROOT、AGENT_SKILLS_ROOT
确认搜索边界覆盖业务仓库
确认相关长期上下文已读取
```

## Gate 1：brownfield-analysis

人工调用：

```text
brownfield-analysis
```

目标：

> 还原历史系统真实现状和变更影响范围。

输出：

```text
openspec/changes/<change-id>/00-change-analysis.md
```

本阶段：

```text
只分析
不修改业务代码
```

完成后人工 Review。

重点确认：

- 需求理解是否正确
- 业务入口是否完整
- 调用链是否完整
- 涉及仓库是否完整
- 数据影响是否完整
- 分布式影响是否完整
- 风险是否完整

## Gate 2：OpenSpec propose

基于：

- 原始需求
- project-context
- rules
- 00-change-analysis.md

创建 OpenSpec Change。

Proposal 至少覆盖：

- 涉及模块
- 涉及仓库
- 数据库影响
- 接口影响
- Dubbo / RPC 影响
- MQ 影响
- Job 影响
- 风险
- 兼容性

## Gate 3：change-design

根据：

```text
00-change-analysis.md
proposal
specs
```

完成设计。

设计必须说明：

- 现状
- 目标
- 修改方案
- 数据变化
- 调用链变化
- 事务边界
- 并发策略
- 幂等策略
- 重试和补偿
- 历史兼容
- 回滚方案

## Gate 4：tasks 与 design-review

人工调用：

```text
design-review
```

审查：

- Requirement Coverage
- Analysis Alignment
- Data Safety
- Distributed Consistency
- Compatibility
- Tasks Executability

存在 Blocker 时：

```text
禁止进入实现
```

Tasks 必须覆盖 Design 的全部实现点和验证点，且不得要求实现 Agent 重新猜测业务语义。

## 人工 Review

人工确认：

- 系统理解
- 影响范围
- 设计方案
- 风险
- 兼容策略

确认后进入实现。

## Gate 5：OpenSpec apply

严格依据：

```text
00-change-analysis.md
proposal
specs
design
tasks
```

实现。

禁止：

- 擅自扩大范围
- 无依据重构
- 修改无关代码

如果真实代码与设计冲突：

```text
停止扩大实现
↓
记录冲突
↓
返回 change-design
```

## Gate 6：verification

人工调用：

```text
verification
```

输出：

```text
verification-report.md
```

检查：

- Requirement Coverage
- Design Conformance
- Build
- Test
- Scenario
- Compatibility

## Gate 7：change-review

先生成或读取 Diff Summary：

```powershell
scripts/change-diff-summary.ps1 -ChangeId <change-id> -ProjectRoot <workspace-root>
```

然后人工调用：

```text
change-review
```

基于所有相关仓库实际 Diff 和 `diff-summary.md` 审查。

重点检查：

- 遗漏修改
- 超范围修改
- 历史兼容
- SQL
- 金额/数量/权限
- 事务
- 并发
- 锁
- 幂等
- RPC
- MQ
- Job
- 日志
- 测试

## Gate 8：context-sync

人工调用：

```text
context-sync
```

或手工执行 Context Sync，检查：

```text
project-context
rules
integration registry
runtime config registry
agent handoff
```

是否需要同步。

长期系统知识必须沉淀。

context-sync 必须区分：

- 可同步长期事实
- 可同步长期规则
- 不可同步内容
- 待确认问题
- Context Drift

单次需求细节保留在 Change。

如果发现长期事实只存在于 `openspec/changes/<change-id>/`，不得直接 archive；应先同步到 `openspec/project-context/` 或 `openspec/rules/`。

## OpenSpec archive

归档条件：

- Gate 6 Verification 通过或人工接受剩余检查项。
- Gate 7 Change Review 通过。
- Gate 8 Context Sync 已完成。
- 未关闭的阻塞项已解决或明确由人工接受。

## 阶段门禁

除非人工明确豁免，否则按以下结论推进：

| 阶段 | 可进入下一阶段 | 必须停止 |
|---|---|---|
| brownfield-analysis | `00-change-analysis.md` 完成，且结论建议进入下一阶段 | 分析范围缺失、存在阻塞性待确认问题 |
| design-review | `PASS` 或 `PASS_WITH_NON_BLOCKING_COMMENTS` | `BLOCKED` |
| verification | `PASS` 或 `PASS_WITH_MANUAL_CHECKS` 且人工检查项已有 Owner | `FAIL` 或 `BLOCKED` |
| change-review | `PASS` 或 `PASS_WITH_NON_BLOCKING_COMMENTS` | `BLOCKED` |
| context-sync | 长期事实已同步或明确无需同步，handoff 已记录 | 存在 Context Drift 未处理、长期事实只留在 change |

`PASS_WITH_*` 只能包含非阻塞问题；凡是会影响需求正确性、数据安全、兼容性或上线回滚的问题，必须判定为 `BLOCKED` 或 `FAIL`。
