# 默认变更流程

## Phase 1：brownfield-analysis

人工调用：

```text
brownfield-analysis
```

目标：

> 还原历史系统真实现状和变更影响范围。

输出：

```text
openspec/changes/<change-id>/00-change-analysis.md
```

本阶段：

```text
只分析
不修改业务代码
```

完成后人工 Review。

重点确认：

- 需求理解是否正确
- 业务入口是否完整
- 调用链是否完整
- 涉及仓库是否完整
- 数据影响是否完整
- 分布式影响是否完整
- 风险是否完整

## Phase 2：OpenSpec propose

基于：

- 原始需求
- project-context
- rules
- 00-change-analysis.md

创建 OpenSpec Change。

Proposal 至少覆盖：

- 涉及模块
- 涉及仓库
- 数据库影响
- 接口影响
- Dubbo / RPC 影响
- MQ 影响
- Job 影响
- 风险
- 兼容性

## Phase 3：change-design

根据：

```text
00-change-analysis.md
proposal
specs
```

完成设计。

设计必须说明：

- 现状
- 目标
- 修改方案
- 数据变化
- 调用链变化
- 事务边界
- 并发策略
- 幂等策略
- 重试和补偿
- 历史兼容
- 回滚方案

## Phase 4：design-review

人工调用：

```text
design-review
```

审查：

- Requirement Coverage
- Analysis Alignment
- Data Safety
- Distributed Consistency
- Compatibility
- Tasks Executability

存在 Blocker 时：

```text
禁止进入实现
```

## Phase 5：人工 Review

人工确认：

- 系统理解
- 影响范围
- 设计方案
- 风险
- 兼容策略

确认后进入实现。

## Phase 6：OpenSpec apply

严格依据：

```text
00-change-analysis.md
proposal
specs
design
tasks
```

实现。

禁止：

- 擅自扩大范围
- 无依据重构
- 修改无关代码

如果真实代码与设计冲突：

```text
停止扩大实现
↓
记录冲突
↓
返回 change-design
```

## Phase 7：verification

人工调用：

```text
verification
```

输出：

```text
verification-report.md
```

检查：

- Requirement Coverage
- Design Conformance
- Build
- Test
- Scenario
- Compatibility

## Phase 8：change-review

人工调用：

```text
change-review
```

基于所有相关仓库实际 Diff 审查。

重点检查：

- 遗漏修改
- 超范围修改
- 历史兼容
- SQL
- 金额
- 事务
- 并发
- 锁
- 幂等
- RPC
- MQ
- Job
- 日志
- 测试

## Phase 9：OpenSpec archive

归档前检查：

```text
project-context
rules
```

是否需要同步。

长期系统知识必须沉淀。

单次需求细节保留在 Change。
