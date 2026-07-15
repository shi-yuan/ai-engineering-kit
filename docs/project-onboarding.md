# 项目接入指南

## 一、推荐目录

例如：

```text
xyy-pop/
├── AGENTS.md
├── .agent-env.md
├── openspec/
│   ├── config.yaml
│   ├── agent/
│   │   └── project-rules.md
│   ├── rules/
│   ├── project-context/
│   └── changes/
├── xyy-pop-core/
└── xyy-pop-business/
```

OpenSpec 可以是独立 Git 仓库。

但是 Agent Workspace 必须打开：

```text
xyy-pop/
```

不得只打开：

```text
xyy-pop/openspec/
```

原因：

> Agent 的代码搜索边界必须覆盖所有相关业务仓库。

## 二、创建 .agent-env.md

项目根目录创建：

```text
.agent-env.md
```

内容：

```text
AI_ENGINEERING_KIT_VERSION=1.1.1
AI_ENGINEERING_KIT_HOME=<ai-engineering-kit 仓库绝对路径>
WORKSPACE_ROOT=.
OPEN_SPEC_ROOT=./openspec
AGENT_SKILLS_ROOT=./openspec/agent/skills
```

如果 OpenSpec 实际目录名称为：

```text
xyy-pop-openspec
```

则配置：

```text
OPEN_SPEC_ROOT=./xyy-pop-openspec
```

## 三、创建 AGENTS.md

基于：

```text
AGENTS.base.md
```

创建项目：

```text
AGENTS.md
```

项目 AGENTS.md 可以增加：

- 项目名称
- Workspace 结构
- OpenSpec 路径
- 项目特殊规则入口

不要将所有专项规则复制进 AGENTS.md。

## 四、规则分层

### AGENTS.md

Agent 统一入口和全局执行规则。

### project-rules.md

项目总体工程规则。

例如：

- Java 版本
- Spring Boot 版本
- MyBatis 使用规范
- 金额规则
- 项目模块关系

### rules/*.md

专项规则。

例如：

```text
rules/payment.md
rules/bill.md
rules/settlement.md
rules/withdraw.md
rules/database.md
rules/money.md
rules/dubbo.md
rules/mq.md
```

### project-context/*.md

长期系统事实。

例如：

```text
system-overview.md
architecture.md
module-map.md
data-model.md
payment-flow.md
bill-flow.md
settle-flow.md
withdraw-flow.md
```

### changes/<change-id>/

单次变更事实。

## 五、config.yaml

OpenSpec config 应声明：

- 必须读取 project-context
- 必须基于真实代码分析
- 不得猜测
- Proposal 必须覆盖影响范围
- 实现后检查 Context 更新

完整专项规则不要全部写入 config.yaml。

## 六、首次接入步骤

1. 团队统一保存 AI Engineering Kit。
2. Agent 打开项目外层 Workspace。
3. 基于 AGENTS.base.md 创建 AGENTS.md。
4. 创建 .agent-env.md。
5. 完善 project-rules.md。
6. 按需增加 rules。
7. 检查 project-context。
8. 选择一个中等复杂度历史需求试点。
9. 人工调用 brownfield-analysis。
10. Review 00-change-analysis.md。
11. 进入 OpenSpec propose。
12. 完成 design-review。
13. 人工 Review。
14. OpenSpec apply。
15. verification。
16. change-review。
17. archive。

V1.1.1 建议人工控制阶段切换。

日常需求执行步骤、rules / project-context / project-rules 编写建议，参见：

```text
docs/practice-guide.md
docs/kit-discovery.md
```
