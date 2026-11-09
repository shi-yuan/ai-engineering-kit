# context-sync

## 一、目标

在变更完成并通过 verification、change-review 后，将长期有效的系统事实和工程约束同步到项目上下文。

本 Skill 对应：

```text
Gate 8 Context Sync
```

本 Skill：

```text
允许修改 OpenSpec 文档
不修改业务代码
```

## 二、输入

读取：

- `AGENTS.md`
- `.agent-env.md`
- `openspec/config.yaml`
- `openspec/agent/project-rules.md`
- `openspec/rules/change-gates.md`
- 相关 `openspec/rules/*.md`
- 相关 `openspec/project-context/*.md`
- `openspec/changes/<change-id>/00-change-analysis.md`
- proposal
- specs
- design
- tasks
- verification-report.md
- change-review.md 或 Review 结论
- 实际 Diff 摘要

## 三、同步范围

长期系统知识进入：

```text
openspec/project-context/
```

包括：

- 新确认的业务不变量。
- 新确认的模块职责和调用链。
- 新确认的表、字段、状态、业务键、索引约束。
- 新确认的 RPC Provider/Consumer。
- 新确认的 MQ Topic、Tag、Producer、Consumer、Group。
- 新确认的 Job、补偿任务、对账任务。
- 新确认的外部系统接口、状态映射、回调/查询/对账机制。
- 新确认的运行态配置、开关、默认值。

长期工程约束进入：

```text
openspec/rules/
```

包括：

- 以后同类变更必须遵守的规则。
- 已被本次变更证明需要前置检查的约束。
- 可复用的验证规则。

单次需求细节保留在：

```text
openspec/changes/<change-id>/
```

## 四、禁止事项

- 不得把未确认推断写入长期上下文。
- 不得把单次需求临时方案写入长期规则。
- 不得用文档覆盖真实代码事实。
- 不得为了归档而删除 Context Drift。
- 不得修改业务代码。

## 五、执行步骤

### Step 1：提取候选事实

从 analysis、design、verification、change-review 中提取候选长期事实。

每条候选事实必须标明证据来源。

证据链接可以是：

- 代码路径
- 配置路径
- DDL / SQL
- 接口文档
- 测试证据
- 人工确认记录

### Step 2：分类

判断每条内容应进入：

- 可同步长期事实：进入 `project-context`
- 可同步长期规则：进入 `rules`
- 不可同步内容：保留在 `changes/<change-id>` 或丢弃
- 待确认问题：记录 Owner 和阻塞阶段
- Context Drift：记录冲突位置、真实代码行为和处理方式

### Step 3：处理 Context Drift

如果文档与真实代码冲突：

1. 记录冲突位置。
2. 说明真实代码当前行为。
3. 标记待确认问题。
4. 不把冲突结论写成确定事实。

### Step 4：更新文档

按最小必要原则更新 OpenSpec 文档。

优先更新已有文件；只有当现有结构无法承载长期事实时才新增文件。

### Step 5：输出报告

使用：

```text
templates/context-sync-report.md
```

输出：

```text
openspec/changes/<change-id>/context-sync-report.md
```

## 六、完成标准

完成后必须说明：

- 可同步长期事实、实际同步位置和证据链接。
- 可同步长期规则、实际同步位置和证据链接。
- 不可同步内容及原因。
- 待确认问题、Owner 和是否阻塞 archive。
- Context Drift 的冲突位置、真实代码行为和处理方式。
- 是否建议进入 OpenSpec archive。
