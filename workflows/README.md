# Workflow 使用说明

## 一、V1.1.1 Workflow 定位

V1.1.1 中 Workflow 是：

> 人工执行指南。

不是自动编排引擎。

开发人员人工选择并调用 Skill。

每个阶段完成后，由人工 Review 决定是否进入下一阶段。

## 二、为什么暂不自动化

大型历史项目中：

- 项目上下文完整度不同
- Agent 能力不同
- 需求复杂度不同
- 历史技术债不同

如果过早自动编排，可能导致：

```text
错误分析
↓
自动 propose
↓
自动 design
↓
自动 apply
↓
批量生成错误代码
```

因此 V1.1.1 推荐：

```text
Skill 人工触发
+
阶段人工 Review
```

## 三、Agent 无关

Skill 不绑定：

- Claude Code
- CodeBuddy
- Codex

Agent 只是执行器。

OpenSpec artifacts 是 Agent 之间的事实交接载体。

## 四、未来演进

流程稳定后可以增加：

```text
workflow-state.yaml
Human Gate
自动阶段检查
自动 Requirement Coverage
自动 Context Drift Detection
```

然后升级为真正的自动 Workflow。
