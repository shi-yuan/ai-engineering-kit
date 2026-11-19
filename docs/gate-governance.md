# Gate 治理实践

## 核心原则

大型历史复杂业务系统不适合让 AI 直接从需求跳到编码。AI Coding 的生产化落地，应当把 Agent 变成"证据驱动的工程协作者"，而不是"自动改代码机器"。

默认 Gate：

```text
需求
  ↓
Gate 0 Context Loading
  ↓
Gate 1 Brownfield Analysis
  ↓
00-change-analysis.md
  ↓
Gate 2 OpenSpec Proposal
  ↓
Gate 3 Change Design
  ↓
Gate 4 Tasks
  ↓
Design Review
  ↓
人工 Review
  ↓
Gate 5 Apply
  ↓
Gate 6 Verification
  ↓
Gate 7 Change Review
  ↓
人工 Code Review
  ↓
Gate 8 Context Sync
  ↓
OpenSpec Archive
```

## 为什么要 Gate

Gate 解决的是历史项目里的典型返工来源：

- AI 只理解局部代码。
- 跨仓库影响分析不完整。
- Proposal 基于错误现状。
- Design 与真实代码不一致。
- 实现阶段擅自扩大范围。
- 验证只覆盖 happy path。
- Agent 切换后上下文丢失。
- 长期系统事实没有沉淀。

## 需求分类

| 类型 | 判断标准 | 流程 |
|---|---|---|
| A 全新独立功能 | 新模块、新入口、新表，与历史状态和上下游无强耦合 | 可轻量分析，但必须保留 Proposal、Design、Tasks、Verification |
| B 历史功能增强 | 修改既有接口、状态、表、消息、任务、报表、兼容逻辑 | 必须执行完整 Gate 及人工 Code Review |
| C 高风险核心变更 | 涉及资金、库存、授信、合同、权限、计费、清结算、履约等 | 完整 Gate + 人工关键事实确认 + 架构/业务 Review + 人工 Code Review + 上线风险清单 |

## 团队落地建议

- 把 `00-change-analysis.md` 作为历史需求进入 Proposal 的准入材料。
- 把 design-review 作为实现前的强制审查。
- 把 verification-report 作为代码合并前的证据材料。
- 需要真实容器语义（鉴权、序列化、实际 SQL、中间件联动、跨服务链路）的验证项，优先走
  `api-verification` 接口实测（项目提供 custom-skills 同名实例登记适配点后启用），
  其产物（.http 用例、验证报告、api-docs 快照、响应落盘）一并归入合并前证据。
- 把 change-review 作为最终 Diff 审查，不只看风格。
- 把人工 Code Review（`code-review` / `sql-review`）作为提测或上线前的最后代码质量关卡：AI 先产出评审证据（diff-summary、change-review 结论、评审报告），专业同学做最终确认；涉及 DDL 时先跑 sql-review。规则内容项目相关，放在项目 `custom-skills/` 覆盖 Kit 通用骨架。
- 把 context-sync 作为 archive 前置条件，避免知识只留在一次性 change。
- 不要求所有需求都重流程；但凡影响历史状态、数据、接口或异步链路，就不要跳过分析。

## 生产化辅助检查

在人工 Gate 基础上，建议使用以下脚本作为最低机器检查：

```powershell
scripts/lint-kit.ps1
scripts/check-change.ps1 -ChangeId <change-id> -NextGate apply
scripts/check-change.ps1 -ChangeId <change-id> -NextGate code-review
scripts/change-diff-summary.ps1 -ChangeId <change-id> -ProjectRoot <workspace-root>
```

这些脚本不替代人工 Review，但用于提前拦截缺失 artifact、版本漂移、manifest 失效、明显超范围修改和遗漏声明。
