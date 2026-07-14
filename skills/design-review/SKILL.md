# Design Review

## 目标

在实现开始前，使用需求、Change Analysis、project-context
和真实代码证据审查 OpenSpec proposal、specs、design、tasks。

目标是尽早发现：

-   错误业务假设
-   影响范围遗漏
-   跨仓遗漏
-   Design 与当前实现不匹配
-   Task 无法完整落实 Design

本 Skill 不修改生产代码。

## 输入

-   `.agent-env.md`
-   当前需求目录
-   `20-change-analysis.md`
-   当前 OpenSpec change 全部 Artifact
-   相关 project-context
-   必要的实现代码

## 输出

在当前 OpenSpec change 目录生成或更新：

`design-review.md`

最终结论只能是：

-   `PASS`
-   `PASS WITH REQUIRED FIXES`
-   `BLOCKED`

## 执行步骤

### 1. 重建变更意图

重新读取原始需求和 `20-change-analysis.md`。

明确：

-   当前行为
-   目标行为
-   需求 Delta
-   已验证业务不变量
-   影响仓库和系统边界

### 2. 联合审查 OpenSpec Artifact

将 proposal、specs、design、tasks 作为一个整体检查。

检查 Artifact 之间是否互相一致。

重点检查：

-   proposal 是否准确描述问题和范围
-   specs 是否描述可验证行为
-   design 是否解释关键技术决策
-   tasks 是否足以完整落实 design
-   tasks 是否包含跨仓修改和 Verification

### 3. 证据交叉验证

对每个关键 Design 决策：

1.  找到它依赖的当前系统事实。
2.  在 `20-change-analysis.md` 中找到对应证据。
3.  对高风险、模糊或证据不足的决策重新检查代码。
4.  标记无证据支持的 Design 假设。

Change Analysis 不是绝对正确，Review 必须允许反向发现分析错误。

### 4. 反向影响分析

从"拟修改点"反向检查谁会观察或依赖它。

至少考虑：

-   调用方和被调用方
-   数据读取方和写入方
-   消息生产方和消费方
-   Job、补偿、对账、修复流程
-   状态流转上下游
-   缓存和配置行为
-   事务和并发边界
-   历史数据与新数据兼容

### 5. 业务不变量检查

逐条检查 `20-change-analysis.md` 中的不变量：

-   Design 是否保持它
-   如果要改变，需求是否明确要求
-   specs 是否描述新行为
-   tasks 和 Verification 是否覆盖

### 6. Task 可执行性检查

Task 必须能让实现 Agent 在不重新猜业务的情况下执行。

禁止出现只有结果、没有边界的 Task，例如：

`优化提现逻辑`

更合适的 Task 应明确：

-   修改目标
-   涉及仓库 / 模块
-   需要保持的关键语义
-   需要验证的结果

### 7. 输出 Review

使用 `templates/design-review.md`。

完成前执行 `references/review-checklist.md`。

## 结论规则

### PASS

没有阻断问题，也没有必须先修复的问题。

### PASS WITH REQUIRED FIXES

Design 主方向正确，但存在明确必须修复的 Artifact 问题。

修复并复核前不得 apply。

### BLOCKED

存在以下任一情况：

-   Design 建立在错误当前行为之上
-   关键业务规则仍未确认
-   重大跨仓或集成影响遗漏
-   方案与现有架构明显冲突且无充分理由
-   proposal/spec/design/tasks 之间重大矛盾

不得用"实现时再看"掩盖 Design 阶段的关键不确定性。
