# AI Engineering Kit V1.2.0

面向大型历史项目、多仓库、复杂业务系统的生产化 AI 辅助开发工程规范。

本 Kit 重点解决以下问题：

- AI 修改历史复杂项目时只理解局部代码。
- 跨仓库影响分析不完整。
- AI 过早进入编码阶段。
- OpenSpec Proposal 基于错误或不完整的系统理解。
- Claude Code、CodeBuddy、Codex 等 Agent 切换时上下文丢失。
- AI 生成代码返工量大。
- 设计、实现和最终代码之间缺少一致性检查。

## 一、核心思想

AI Engineering Kit 不依赖单一 Agent。

支持：

- Claude Code
- CodeBuddy
- Codex
- 其他支持读取 Markdown 指令的 Coding Agent

核心原则：

> Agent 可以切换，工程事实不能丢失。

OpenSpec 是变更事实中心。

长期系统知识存放于：

```text
openspec/project-context/
openspec/rules/
```

单次变更知识存放于：

```text
openspec/changes/<change-id>/
```

## 二、默认工作流

```text
需求
  ↓
Gate 0 Context Loading
  ↓
Gate 1 brownfield-analysis
  ↓
00-change-analysis.md
  ↓
Gate 2 OpenSpec propose
  ↓
Gate 3 change-design
  ↓
Gate 4 tasks
  ↓
design-review
  ↓
人工 Review
  ↓
Gate 5 OpenSpec apply
  ↓
Gate 6 verification
  ↓
Gate 7 change-review
  ↓
人工 Code Review
  ↓
Gate 8 context-sync
  ↓
OpenSpec archive
```

V1.2.0 默认采用：

> 人工调用 Skill，人工控制阶段切换。

暂不自动编排 Workflow。

当团队流程稳定后，可以升级为自动 Workflow。

## 三、需求分类

不是所有需求都需要同等重量的流程。

| 类型 | 判断标准 | 推荐流程 |
|---|---|---|
| A 全新独立功能 | 新模块、新入口、新表，与历史状态和上下游无强耦合 | 可轻量分析，但必须保留 Proposal、Design、Tasks、Verification |
| B 历史功能增强 | 修改既有接口、状态、表、消息、任务、报表、兼容逻辑 | 必须执行完整 Gate 及人工 Code Review |
| C 高风险核心变更 | 涉及资金、库存、授信、合同、权限、计费、清结算、履约等 | 完整 Gate + 人工关键事实确认 + 架构/业务 Review + 人工 Code Review + 上线风险清单 |

本 Kit 的核心不是让 AI 自动接管历史项目，而是让 AI 在证据驱动的 Gate 治理下稳定参与需求交付。

## 四、为什么先做 brownfield-analysis

对于全新功能，AI 通常能够根据清晰需求完成设计和编码。

但是历史复杂系统通常存在：

- 隐式业务规则
- 历史兼容逻辑
- 多仓库调用
- Dubbo RPC
- MQ 异步链路
- Job 补偿任务
- Redis 状态
- Apollo 配置
- 事务边界
- 分布式锁
- CAS
- 幂等
- 重试
- 补偿

如果 AI 在理解这些内容之前直接进入设计或编码阶段，通常会产生大量返工。

因此历史功能修改必须先执行：

```text
brownfield-analysis
```

输出：

```text
00-change-analysis.md
```

然后再进入 OpenSpec propose。

## 五、仓库结构

```text
ai-engineering-kit/
├── VERSION
├── README.md
├── AGENTS.base.md
│
├── adapters/
│   ├── CLAUDE.md
│   ├── CODEBUDDY.md
│   └── CODEX.md
│
├── workflows/
│   ├── README.md
│   └── default-change-flow.md
│
├── skills/
│   ├── manifest.yaml
│   ├── brownfield-analysis/
│   │   ├── SKILL.md
│   │   └── templates/
│   │       └── 00-change-analysis-template.md
│   │
│   ├── design-review/
│   │   └── SKILL.md
│   │
│   ├── verification/
│   │   └── SKILL.md
│   │
│   ├── change-review/
│   │   └── SKILL.md
│   │
│   ├── code-review/
│   │   └── SKILL.md
│   │
│   ├── sql-review/
│   │   └── SKILL.md
│   │
│   └── context-sync/
│       └── SKILL.md
│
└── docs/
    ├── gate-governance.md
    ├── context-sync.md
    ├── project-onboarding.md
    ├── practice-guide.md
    ├── kit-discovery.md
    └── project-file-examples.md
```

## 六、项目接入

推荐项目 Workspace：

```text
xyy-pop/
├── AGENTS.md
├── .agent-env.md
├── CLAUDE.md
├── CODEBUDDY.md
├── CODEX.md
├── xyy-pop-core/
├── xyy-pop-business/
└── openspec/
    ├── config.yaml
    ├── agent/
    │   ├── project-rules.md
    │   └── skills/
    │       └── manifest.yaml
    ├── rules/
    ├── project-context/
    └── changes/
```

从 V1.2.0 开始，`setup-agent` 会在目标项目缺失对应文件时，自动种入通用模板：

```text
openspec/rules/change-gates.md
openspec/rules/database.md
openspec/rules/money.md
openspec/rules/api-compatibility.md
openspec/rules/code-structure.md
openspec/rules/dubbo.md
openspec/rules/feign-rpc.md
openspec/rules/mq.md
openspec/rules/job.md
openspec/rules/redis-cache.md
openspec/rules/transaction-consistency.md
openspec/rules/logging-observability.md
openspec/rules/testing.md
openspec/rules/security-permission.md
openspec/project-context/change-analysis-template.md
openspec/project-context/impact-analysis-guide.md
openspec/project-context/agent-handoff.md
openspec/project-context/integration/integration-registry-template.md
openspec/project-context/runtime-config-template.md
```

已有项目文件不会被覆盖。项目团队应在这些模板基础上沉淀自己的业务上下文、集成注册表和长期规则。

即使 `openspec` 是独立 Git 仓库，也必须从：

```text
xyy-pop/
```

打开 Agent Workspace。

不得只打开：

```text
xyy-pop/openspec/
```

否则 Agent 无法完整分析业务代码。

详细接入和日常实践参见：

```text
docs/project-onboarding.md
docs/practice-guide.md
docs/kit-discovery.md
docs/gate-governance.md
docs/context-sync.md
```

## 七、版本策略

当前版本：

```text
V1.2.0
```

V1.x：

- 人工调用 Skill
- 人工 Review
- OpenSpec 作为事实中心
- Gate 治理
- Context Sync

未来版本可以增加：

- Workflow State
- Human Gate
- 自动阶段切换
- 自动 Requirement Coverage
- 自动 Context Drift Detection
- 自动多仓库 Diff 检查

## 八、生产化校验脚本

V1.2.0 增加以下基础校验脚本：

```powershell
scripts/lint-kit.ps1
scripts/check-change.ps1 -ChangeId <change-id> -NextGate apply
scripts/change-diff-summary.ps1 -ChangeId <change-id> -ProjectRoot <workspace-root>
```

- `lint-kit.ps1`：校验 Kit 版本一致性、manifest entry、必需模板和遗留版本号。
- `check-change.ps1`：检查单个 change 是否满足进入下一 Gate 的最低 artifact 条件。
- `change-diff-summary.ps1`：生成多仓 Diff Summary，对照 design/tasks 识别潜在超范围修改和遗漏声明；
  实现已提交时必须带 `-BaseRef <branch|commit>`，否则 committed 变更不会被采集。

项目自定义 Skill 放入 `openspec/agent/custom-skills/`，`setup-agent` 不会覆盖；公共 Skill 刷新前会备份到 `openspec/agent/skills.backup/`。
