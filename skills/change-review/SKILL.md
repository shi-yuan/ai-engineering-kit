# change-review

## 一、目标

基于所有相关仓库实际 Diff 做最终工程审查。

本 Skill 关注：

> 实际代码最终变成了什么。

不要只评价代码风格。

## 二、输入

读取：

- 00-change-analysis.md
- proposal
- specs
- design
- tasks
- verification-report.md
- 所有相关仓库实际 Diff

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
