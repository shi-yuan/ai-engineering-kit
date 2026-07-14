# Change Review

## 目标

在实现和 Verification 后，对实际跨仓 Diff 做最终变更审查。

核心问题不是"代码写得是否漂亮"，而是：

-   是否正确实现需求
-   是否符合已 Review 的 Design
-   是否破坏历史业务语义
-   是否遗漏联动修改
-   是否引入无关修改

本 Skill 默认不主动重写实现。先输出 Review 结论和问题。

## 输入

-   `.agent-env.md`
-   原始需求
-   `20-change-analysis.md`
-   OpenSpec proposal、specs、design、tasks
-   `design-review.md`
-   `verification.md`
-   所有受影响仓库的完整 Git diff
-   必要的相关历史代码

## 输出

在当前 OpenSpec change 目录生成或更新：

`change-review.md`

结论只能是：

-   `PASS`
-   `PASS WITH REQUIRED FIXES`
-   `BLOCKED`

## 执行步骤

### 1. 收集完整变更

检查所有实现仓库：

-   `git status`
-   `git diff`
-   `git diff --stat`

根据 module map、Change Analysis 和 Design 确认没有漏掉仓库。

### 2. Requirement → Spec → Design → Task → Diff 追溯

对每个需求变化点，检查：

-   是否有 Spec
-   是否有 Design 落点
-   是否有 Task
-   是否有实际 Diff 或明确"不需要代码修改"
-   是否有 Verification

同时反向检查每个主要 Diff：

-   对应哪个 Requirement / Design / Task
-   如果没有对应关系，是否属于无关范围扩张

### 3. 历史业务语义检查

逐条复核 Change Analysis 中的业务规则和不变量。

特别检查：

-   特殊值语义
-   状态流转
-   金额或数量计算
-   顺序和分页
-   部分成功
-   幂等
-   重试和重复执行
-   补偿
-   历史兼容

代码"更简洁"不能作为改变历史语义的理由。

### 4. 跨边界完整性检查

检查：

-   API / RPC 调用双方
-   DTO / 序列化双方
-   消息生产端 / 消费端
-   数据写入方 / 读取方
-   Job / 补偿 / 对账
-   配置读取和默认值
-   缓存更新和失效
-   事务和并发边界

### 5. 错误处理和回滚检查

检查新增或修改路径在以下情况的行为：

-   下游失败
-   超时
-   重试
-   重复调用
-   部分成功
-   数据为空
-   边界值
-   并发执行

### 6. Verification 复核

读取 `verification.md`。

检查：

-   是否覆盖主要 Design 风险
-   是否覆盖关键业务不变量
-   是否存在失败或未执行项
-   人工检查项是否影响上线判断

不得把"编译通过"等同于"业务正确"。

### 7. 输出 Change Review

使用 `templates/change-review.md`。

完成前执行 `references/review-checklist.md`。

## 严重级别

-   `BLOCKER`：会导致核心业务错误、数据错误、严重兼容问题或无法安全上线
-   `HIGH`：重要需求遗漏、明显业务语义错误、关键联动遗漏
-   `MEDIUM`：存在真实缺陷风险，但影响受限
-   `LOW`：非阻断改进

存在未解决 `BLOCKER` 或 `HIGH` 时，不得 `PASS`。
