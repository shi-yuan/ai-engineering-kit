# 架构说明（Architecture）

> 状态：待项目填充（模板）。只记录有代码证据的架构事实；如与真实代码冲突，以真实代码为准并记录 Context Drift。

## 部署与边界

（各模块是否独立工程/独立部署；parent pom 位置；Workspace 内是否有聚合 pom。）

## 模块间调用关系（方向为调用方 → 被调方）

```text
（待填，例如：
moduleA ──► moduleB, 外部系统X
moduleB ──► moduleC）
```

（补充说明调用是否双向、是否存在启动顺序依赖。）

## 分层约定

（包根、分层命名：controller / service / mapper / entity / dto / rpc / config 等；各模块差异化包。）

## 可靠性模式（重点）

- 异步可靠传递方式：MQ 还是 DB Outbox + Job 补偿（写明 Handler/Listener 清单与位置）。
- 幂等/防重机制：Redis / 数据库唯一键 / 状态机等。
- Job 并发控制：分布式锁 / 串行化方式。

## 关键机制

（主键生成、分页/乐观锁插件、本地联调机制、统一响应包装等跨模块共性机制。）
