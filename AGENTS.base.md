# 通用 Agent Engineering Rules

## 1. 工作区模型

当前工作目录可能是一个多 Git 仓库聚合工作区。

不要假设：

-   当前目录本身是 Git 仓库；
-   当前需求只影响单个仓库；
-   当前打开的代码仓库代表完整系统；
-   `openspec/` 一定位于当前目录。

开始任务前必须读取 `.agent-env.md`。

## 2. OpenSpec Root

从 `.agent-env.md` 获取：

`OPEN_SPEC_ROOT`

后续统一按以下路径访问：

``` text
<OPEN_SPEC_ROOT>/project-context
<OPEN_SPEC_ROOT>/requirements
<OPEN_SPEC_ROOT>/changes
<OPEN_SPEC_ROOT>/specs
```

禁止自行猜测 OpenSpec Root。

## 3. 项目规则

本文件后部可能包含由项目 `project-rules.md` 合并生成的项目专属规则。

通用规则与项目规则同时生效。

如果规则冲突：

1.  明确指出冲突；
2.  不得静默选择；
3.  涉及业务正确性、数据安全或兼容性时必须阻断并要求确认。

## 4. 强制上下文

开始分析、设计、实现或 Review 前，根据任务范围读取：

1.  `.agent-env.md`
2.  `<OPEN_SPEC_ROOT>/project-context/system-overview.md`
3.  `<OPEN_SPEC_ROOT>/project-context/architecture.md`
4.  `<OPEN_SPEC_ROOT>/project-context/module-map.md`
5.  `<OPEN_SPEC_ROOT>/project-context/data-model.md`
6.  `<OPEN_SPEC_ROOT>/project-context/business/` 下相关文件
7.  当前需求目录相关文件
8.  当前 OpenSpec Change 已有 Artifact

当前生产代码、数据库定义和实际配置是"当前实现事实"的最终证据。

需求和已确认 Design 用于定义"目标行为"。

项目上下文与代码冲突时必须记录冲突。

## 5. 历史功能修改默认流程

``` text
需求
  ↓
brownfield-analysis
  ↓
20-change-analysis.md
  ↓
OpenSpec propose
  ↓
design-review
  ↓
人工 Review
  ↓
OpenSpec apply
  ↓
verification
  ↓
change-review
  ↓
OpenSpec archive
```

不得因为代码改动行数少而自动跳过 Brownfield Analysis。

只有能够通过代码证据证明修改完全隔离，并且不改变业务语义、数据语义、接口契约、异步行为、事务、并发、幂等、重试或补偿行为时，才允许简化流程。

## 6. 分析规则

分析已有行为时：

-   从真实入口追踪到最终副作用；
-   搜索 `module-map.md` 标识的相关仓库；
-   跨进程调用检查双方；
-   异步链路检查 Producer 和 Consumer；
-   检查数据读写、状态变化和数据所有权；
-   检查配置驱动分支；
-   检查 Job、延迟、重试、补偿、对账和修复；
-   检查事务边界；
-   检查锁、幂等和并发控制；
-   检查特殊值、边界值和历史兼容分支；
-   搜索测试中的隐式业务语义。

禁止仅根据变量名、方法名、注释或单个方法推断业务语义。

必须区分：

-   已验证事实
-   需求变化
-   假设
-   待确认问题

## 7. Design 规则

Design 必须建立在真实当前行为和明确 Requirement Delta 之上。

至少检查：

-   模块和 Git 仓库
-   数据库和历史数据
-   API / RPC / 跨进程契约
-   MQ 和异步链路
-   Job / Retry / Compensation / Reconciliation
-   Transaction / Concurrency / Idempotency
-   Compatibility / Rollout Risk
-   Test / Verification

禁止凭空创建当前项目不存在的服务、表、消息、任务、配置或架构层。

## 8. 实现规则

实现阶段：

-   依据已 Review 的 OpenSpec Artifact；
-   保留需求未明确修改的历史业务语义；
-   不进行无关重构；
-   不静默处理模糊业务规则；
-   代码事实与 Design 冲突时停止冲突部分并记录；
-   每项主要修改应能追溯到 Requirement、Design 或 Task；
-   判断长期项目知识是否需要同步到 project-context。

## 9. Review 规则

Review 必须检查完整跨仓 Diff。

至少验证：

-   Requirement Coverage
-   Design Conformance
-   Business Invariants
-   Cross-repository Completeness
-   Persistence Compatibility
-   Interface Compatibility
-   Async Completeness
-   Transaction / Concurrency
-   Error / Retry / Compensation
-   Verification Evidence
-   Scope Expansion

代码整洁、命名合理、编译通过都不能单独证明业务正确。

## 10. Agent 可替换原则

Claude Code、Codex、CodeBuddy 等 Agent 是可替换执行器。

流程正确性依赖共享 Artifact：

-   `AGENTS.md`
-   `.agent-env.md`
-   `.agents/skills/**`
-   `project-context/**`
-   `requirements/**`
-   `changes/**`

不得把单一 Agent 的私有能力作为流程正确性的必要条件。
