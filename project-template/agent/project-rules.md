# Project Agent Rules

本文件只维护当前项目特有的 Agent 工程规则。

不要复制通用 Brownfield Analysis、Design Review 或 Change Review
流程；这些由共享 `ai-engineering-kit` 维护。

## 1. 项目技术基线

-   Backend：Spring Boot
-   Java：Java 8
-   ORM：MyBatis
-   Database：MySQL
-   Connection Pool：Druid
-   Cache：Redis
-   MQ：RocketMQ
-   Config Center：Apollo
-   RPC：Dubbo

如果实际项目技术栈不同，请修改本节。

## 2. Java 规则

-   必须保持 Java 8 兼容。
-   不得使用更高 Java 版本语法或 API。
-   修改公共枚举、DTO、API 时必须搜索全部使用方。
-   金额计算优先使用 `BigDecimal`，不得引入 `double` / `float`
    精度语义变化。

## 3. MyBatis / MySQL 规则

修改 Mapper 或 SQL 时必须检查：

-   SQL 条件是否改变历史查询范围；
-   `NULL` 语义；
-   排序稳定性；
-   分页方式；
-   批量查询参数规模；
-   索引使用可能性；
-   数据量级；
-   更新条件是否承担并发控制或乐观校验职责。

不得仅因为 SQL 可以执行就判定修改安全。

## 4. Dubbo 规则

修改 Dubbo API、DTO、枚举或方法语义时：

-   必须检查 Provider；
-   必须检查 Consumer；
-   必须检查超时、重试和 `sent` 等调用配置；
-   必须检查新旧版本兼容；
-   不得只修改调用方或实现方后结束分析。

## 5. RocketMQ 规则

修改消息 Topic、Tag、Body、字段或业务语义时：

-   检查 Producer；
-   检查全部 Consumer；
-   检查重复消费；
-   检查重试；
-   检查顺序要求；
-   检查历史消息兼容。

## 6. Apollo 规则

新增或修改 Apollo 配置时：

-   明确配置 Key；
-   明确默认值；
-   检查未配置环境的行为；
-   搜索配置全部读取方；
-   判断是否影响动态刷新语义。

## 7. Redis / Lock 规则

涉及 Redis、分布式锁或幂等 Key 时：

-   检查 Key 维度；
-   检查过期时间；
-   检查锁范围；
-   检查异常释放；
-   检查重复执行；
-   检查与数据库事务的边界关系。

## 8. 项目特有业务规则

在此补充"工程执行约束"。

长期业务事实和业务不变量不要写在这里，应写入：

`openspec/project-context/business/`

示例：

-   修改支付状态时必须检查支付、退款和对账链路。
-   修改账单金额语义时必须检查结算、提现和补偿任务。
