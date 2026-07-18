# design-review

## 一、目标

在实现前审查 OpenSpec：

- Proposal
- Specs
- Design
- Tasks

本 Skill：

```text
只审查
不修改业务代码
```

本 Skill 对应 Gate 4 的实现前审查。若结论为 `BLOCKED`，不得进入 Apply。

## 二、输入

读取：

- 00-change-analysis.md
- proposal
- specs
- design
- tasks
- project-context
- rules
- 相关业务代码
- `openspec/rules/change-gates.md`
- `openspec/project-context/impact-analysis-guide.md`

## 三、审查范围

### Requirement Coverage

检查：

```text
Requirement
↓
Spec
↓
Design
↓
Task
```

是否完整覆盖。

### Analysis Alignment

检查 Design 是否与：

```text
00-change-analysis.md
```

中的真实系统现状一致。

不得仅依据 Proposal 或实现 Agent 的描述判断一致；必须抽查真实代码、配置、Mapper、消息或任务证据。

### Gate Alignment

检查：

- Gate 0 是否完成上下文加载。
- Gate 1 是否存在 `00-change-analysis.md`。
- Gate 2 Proposal 是否可追溯到分析事实。
- Gate 3 Design 是否可追溯到 Requirement、Proposal 和分析事实。
- Gate 4 Tasks 是否覆盖 Design 的实现点和验证点。
- 是否存在阻塞待确认问题被写成已确认设计前提。

### Repository Coverage

检查是否遗漏：

- API 仓库
- Core 仓库
- Business 仓库
- Consumer
- Job
- MQ
- 配置仓库

### Data Safety

检查：

- 状态变化
- 金额/数量/权限变化
- SQL
- 历史数据
- 索引
- 性能
- 数据迁移和回滚

### Distributed Consistency

检查：

- RPC
- MQ
- Job
- 事务
- 并发
- 锁
- CAS
- 幂等
- 重试
- 补偿

### Compatibility

检查：

- 老接口
- 老消费者
- 历史数据
- 灰度
- 新旧逻辑共存
- 回滚

### Tasks Executability

Tasks 必须：

- 可执行
- 可验证
- 指向明确模块
- 与 Design 对齐
- 包含 Verification 和必要的 Context Sync

### Runtime And External Uncertainty

检查：

- 设计是否依赖生产配置、外部系统能力、真实数据分布或 Workspace 外消费者。
- 这些依赖是否已有证据。
- 无证据时是否进入待确认问题，并标明阻塞阶段和 Owner。

## 四、问题等级

### Blocker

可能导致：

- 资金错误
- 数据错误
- 严重兼容问题
- 设计不可实现

### High

高概率导致：

- 业务异常
- 数据不一致
- 大范围返工

### Medium

存在工程风险。

### Low

优化建议。

## 五、输出格式

每个问题必须包含：

- 等级
- 问题
- 证据
- 影响
- 建议
- 阻塞 Gate

最终结论：

```text
PASS
PASS_WITH_NON_BLOCKING_COMMENTS
BLOCKED
```

存在 Blocker：

```text
必须 BLOCKED
```
