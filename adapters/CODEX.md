# Codex Adapter

Codex 必须遵循项目根目录：

```text
AGENTS.md
```

## 历史项目修改

进入实现前检查：

```text
00-change-analysis.md
```

是否存在。

同时检查分析结论是否建议进入下一阶段。

## 实现边界

实现必须以已批准的：

```text
proposal
specs
design
tasks
```

为边界。

禁止自行扩大修改范围。

## Design Conflict

如果发现：

```text
真实代码
≠
Design
```

必须：

1. 报告冲突。
2. 停止扩大实现。
3. 返回设计阶段。

不得自行修改设计语义后继续编码。
