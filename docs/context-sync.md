# Context Sync 实践

## 目的

Context Sync 用于在需求完成后，把可复用、长期有效的系统知识沉淀到项目上下文中，避免下一次 Agent 或人工重新探索同一事实。

## 放在哪里

长期系统知识：

```text
openspec/project-context/
openspec/rules/
```

单次变更细节：

```text
openspec/changes/<change-id>/
```

## 应同步的内容

- 新确认的业务不变量。
- 新确认的模块职责和调用链。
- 新确认的表、字段、状态、业务键、索引约束。
- 新确认的 RPC Provider/Consumer。
- 新确认的 MQ Topic、Tag、Producer、Consumer、Group。
- 新确认的 Job、补偿任务、对账任务。
- 新确认的外部系统接口、状态映射、回调/查询/对账机制。
- 新确认的运行态配置、开关、默认值。
- 可复用的工程规则、禁止事项和验证规则。

## 不应同步的内容

- 某个需求的一次性实现细节。
- 临时方案。
- 未确认推断。
- 已过期的历史结论。
- 与项目无关的通用 AI 提示词。

## 操作顺序

1. 从 `00-change-analysis.md`、design、verification、change-review、code-review 中提取长期事实。
2. 判断事实应进入 `project-context` 还是 `rules`。
3. 更新集成注册表、模块图、数据模型或业务不变量。
4. 记录 Context Drift：文档与真实代码冲突时，以代码当前行为为准，同时标注待确认。
5. 在 change-review 或 handoff 中说明已同步和未同步内容。

## 判定标准

当一个结论未来会帮助另一个需求减少分析成本，且已被代码、配置、DDL、运行态信息或人工确认，它就应该被同步。
