# change-review

## 一、目标

基于所有相关仓库实际 Diff 做最终工程审查。

本 Skill 关注：

> 实际代码最终变成了什么。

不要只评价代码风格。

本 Skill 对应：

```text
Gate 7 Change Review
```

Review 必须基于真实 Diff、代码、配置和验证结果，不得把实现 Agent 的自述当作唯一证据。

## 二、输入

读取：

- 00-change-analysis.md
- proposal
- specs
- design
- tasks
- verification-report.md
- 所有相关仓库实际 Diff
- `openspec/rules/change-gates.md`
- 相关 `openspec/project-context/*.md`

## 三、审查范围

重点检查：

### Diff 完整性

- 是否遗漏仓库
- 是否遗漏模块
- 是否遗漏调用方
- 是否遗漏 Consumer / Job

### Scope

- 是否存在超范围修改
- 是否存在无依据重构
- 是否修改无关代码

### Design

- 是否符合已批准设计
- 是否存在 Design Drift
- 是否实现了未经 Review 的推断
- 是否需要回到设计阶段更新 artifacts

### Compatibility

- 历史数据
- 老接口
- 老消费者
- 老状态
- 灰度兼容

### Database

- SQL 安全
- 更新条件
- 查询条件
- 索引
- 性能

### Money

- BigDecimal
- 精度
- compareTo
- 舍入
- 金额边界

### Quantity / Permission

- 数量单位
- 库存或额度边界
- 租户隔离
- 权限范围
- 组织或商户隔离

### Consistency

- 事务
- 并发
- 锁
- CAS
- 幂等
- 重试
- 补偿

### Distributed

- RPC 异常
- 超时
- MQ 重复消费
- Job 重复执行

### Engineering

- 日志
- 可观测性
- 异常处理
- 测试遗漏
- 文档同步

### Context Sync

- 是否有长期系统事实需要进入 `openspec/project-context/`。
- 是否有可复用工程约束需要进入 `openspec/rules/`。
- 是否需要更新 RPC/MQ/Job/外部系统/运行态配置注册表。
- 是否存在 Context Drift。
- 是否已留下必要 handoff。

## 四、问题等级

```text
Blocker
High
Medium
Low
```

每项必须包含：

- 文件 / 位置
- 问题
- 触发场景
- 影响
- 建议
- 是否阻塞 archive

## 五、最终结论

```text
PASS
PASS_WITH_NON_BLOCKING_COMMENTS
BLOCKED
```

存在 Blocker：

```text
必须 BLOCKED
```
