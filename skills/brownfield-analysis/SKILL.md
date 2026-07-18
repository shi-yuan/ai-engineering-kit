# brownfield-analysis

## 一、目标

历史系统修改前，还原真实系统现状和影响范围。

本 Skill：

```text
只分析
不修改业务代码
```

核心目标：

> 在 OpenSpec propose 之前建立可靠的系统事实基础。

本 Skill 对应：

```text
Gate 1 Brownfield Analysis
```

## 二、适用场景

适用于：

- 历史功能修改
- 复杂业务规则调整
- 多仓库变更
- 资金业务
- 支付业务
- 结算业务
- 提现业务
- 订单业务
- RPC 链路修改
- MQ 链路修改
- Job 修改

纯全新独立功能可以根据实际情况简化。

## 三、输入

执行前读取：

1. `AGENTS.md`
2. `.agent-env.md`
3. `openspec/config.yaml`
4. `openspec/agent/project-rules.md`
5. `openspec/rules/change-gates.md`
6. 相关 `openspec/rules/*.md`
7. `openspec/project-context/impact-analysis-guide.md`
8. `openspec/project-context/change-analysis-template.md`
9. 相关 `openspec/project-context/*.md`
10. 原始需求
11. 当前 Change
12. Workspace 业务代码

## 四、执行步骤

### Step 1：理解需求

提取：

- 业务目标
- 核心规则
- 边界条件
- 非本次范围
- 需求分类：A 全新独立功能 / B 历史功能增强 / C 高风险核心变更

禁止直接根据需求描述推断现有系统实现。

### Step 2：定位业务入口

搜索：

- Controller
- API
- Dubbo Provider
- Dubbo Consumer
- Service
- MQ Consumer
- Listener
- Job
- Event Handler

记录真实入口。

### Step 3：还原调用链

从入口向下分析：

```text
入口
↓
Service
↓
Manager / Domain
↓
Mapper / RPC / MQ
```

同时反向搜索：

- 关键方法调用方
- 接口调用方
- 表使用方
- MQ Producer / Consumer
- 配置使用方

不得只分析单向调用链。

### Step 4：分析数据

检查：

- 表
- 字段
- 业务键
- 状态字段
- 金额字段
- 查询条件
- 更新条件
- 历史数据
- 索引
- SQL 性能

必须关注状态变化和金额变化。

### Step 5：分析分布式影响

检查：

- Dubbo / RPC
- MQ
- Job
- Redis
- Apollo
- Cache
- Event

分析：

- 调用方
- 消费方
- 重试
- 超时
- 重复执行
- 最终一致性

### Step 6：分析安全边界

检查：

- 事务边界
- 并发
- 分布式锁
- CAS
- 幂等
- 重复请求
- 重复消费
- 重复 Job
- 重试
- 补偿

### Step 7：分析历史兼容

检查：

- 历史数据
- 老接口
- 老消费者
- 老状态
- 老配置
- 灰度期间新旧逻辑共存

### Step 8：区分事实和推断

分析结果必须分为：

```text
已确认事实
基于代码的合理推断
待确认问题
```

不得将推断写成事实。

### Step 9：给出 Gate 结论

明确：

- 是否建议进入 OpenSpec propose。
- 哪些待确认问题会阻塞 Proposal。
- 哪些待确认问题可作为非阻塞风险进入后续 Review。
- 高风险核心变更是否需要人工关键事实确认、架构 Review 或业务 Review。

## 五、输出

使用：

```text
templates/00-change-analysis-template.md
```

如果项目中存在：

```text
openspec/project-context/change-analysis-template.md
```

优先使用项目模板。

输出：

```text
openspec/changes/<change-id>/00-change-analysis.md
```

## 六、完成标准

以下内容必须覆盖：

- 需求目标
- 业务入口
- 主调用链
- 反向调用关系
- 涉及仓库
- 涉及模块
- 数据影响
- RPC 影响
- MQ 影响
- Job 影响
- Redis / Apollo 影响
- 事务
- 并发
- 锁
- 幂等
- 重试
- 补偿
- 历史兼容
- 风险
- 待确认问题
- Gate 结论
- Proposal 建议范围
- Verification 建议

未完成以上分析，不建议进入 OpenSpec propose。
