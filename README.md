# AI Engineering Kit V1.1.1

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
brownfield-analysis
  ↓
00-change-analysis.md
  ↓
OpenSpec propose
  ↓
change-design
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

V1.1.1 默认采用：

> 人工调用 Skill，人工控制阶段切换。

暂不自动编排 Workflow。

当团队流程稳定后，可以升级为自动 Workflow。

## 三、为什么先做 brownfield-analysis

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

## 四、仓库结构

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
│   └── change-review/
│       └── SKILL.md
│
└── docs/
    ├── project-onboarding.md
    ├── practice-guide.md
    ├── kit-discovery.md
    └── project-file-examples.md
```

## 五、项目接入

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
```

## 六、版本策略

当前版本：

```text
V1.1.1
```

V1.x：

- 人工调用 Skill
- 人工 Review
- OpenSpec 作为事实中心

未来版本可以增加：

- Workflow State
- Human Gate
- 自动阶段切换
- 自动 Requirement Coverage
- 自动 Context Drift Detection
- 自动多仓库 Diff 检查
