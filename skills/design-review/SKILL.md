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
- 金额变化
- SQL
- 历史数据
- 索引
- 性能

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
