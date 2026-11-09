# Module Map

本文件记录多仓聚合项目的仓库、模块和跨仓关系，帮助 Agent 在 brownfield-analysis 阶段确定搜索边界。

## 项目仓库

| 仓库 | 聚合目录相对路径 | 职责 | 主要技术边界 |
|---|---|---|---|
| xyy-pop-api | xyy-pop-api/ | API、DTO、枚举定义 | Dubbo API / DTO |
| xyy-pop-core | xyy-pop-core/ | 核心领域服务 | MySQL / Redis / Dubbo Provider |
| xyy-pop-business | xyy-pop-business/ | 业务编排 | Dubbo Consumer / MQ Producer |
| xyy-pop-job | xyy-pop-job/ | 定时、补偿、对账任务 | Job / MQ Consumer / DB |

## 跨仓关系

| 调用方 / Producer | 被调用方 / Consumer | 机制 | 主要用途 |
|---|---|---|---|
| xyy-pop-business | xyy-pop-core | Dubbo | 查询或变更核心业务数据 |
| xyy-pop-core | xyy-pop-job | DB / Job | 补偿、对账、修复 |
| payment-service | bill-service | MQ | 支付成功后生成账单 |

## Agent 搜索规则

分析需求时：

1. 先根据业务域确定候选仓库。
2. 搜索入口和核心 Domain Symbol。
3. 遇到跨进程调用，继续搜索 Provider / Consumer。
4. 遇到消息，继续搜索 Producer / Consumer。
5. 遇到共享 DTO、API 或数据表，检查所有使用方。
6. 不得因为需求名称属于某个模块就停止跨仓调查。
7. 已检查但不受影响的仓库，也要在 `00-change-analysis.md` 中说明原因。
