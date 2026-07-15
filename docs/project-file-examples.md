# 项目文件示例

## 一、AGENTS.md

```markdown
# xyy-pop Agent Rules

项目名称：xyy-pop

Workspace Root：

当前目录。

OpenSpec Root：

openspec

本项目使用：

AI Engineering Kit V1.1.1

执行任务前必须读取：

1. `.agent-env.md`
2. `openspec/config.yaml`
3. `openspec/agent/project-rules.md`
4. 相关 `openspec/rules/*.md`
5. 相关 `openspec/project-context/*.md`
6. 当前 OpenSpec Change

历史功能变更必须先执行：

brownfield-analysis

不得只分析 openspec 仓库。

代码搜索范围是整个 Workspace。
```

## 二、.agent-env.md

```text
AI_ENGINEERING_KIT_VERSION=1.1.1
WORKSPACE_ROOT=.
OPEN_SPEC_ROOT=./openspec
```

## 三、project-rules.md

```markdown
# Project Rules

## 技术栈

- Java 8
- Spring Boot
- MyBatis
- MySQL
- Druid
- Redis
- RocketMQ
- Apollo
- Dubbo

## 项目规则

- 分析必须基于真实代码和 project-context。
- 不得根据类名和方法名猜测业务。
- 金额处理必须检查 BigDecimal 精度和比较方式。
- 资金状态变化必须检查事务、并发、幂等和补偿。
- Dubbo 接口修改必须分析消费者兼容性。
- MQ 修改必须分析重复消费和历史消息兼容。
- Job 修改必须分析重复执行。
- 实现后必须检查 project-context 和 rules 是否需要更新。
```

## 四、brownfield-analysis 调用示例

```text
按照 AI Engineering Kit V1.1.1 的
brownfield-analysis Skill 分析当前需求。

Change ID：
withdraw-online-amount-refactor

需求：
提现时优先扣减在线支付可提现金额，
不足部分使用商户余额补充。

读取：

AGENTS.md
.agent-env.md
openspec/config.yaml
openspec/agent/project-rules.md
相关 rules
相关 project-context

以 WORKSPACE_ROOT 为代码搜索边界。

必须分析所有相关仓库。

只分析，不修改业务代码。

输出：

openspec/changes/withdraw-online-amount-refactor/00-change-analysis.md
```

## 五、design-review 调用示例

```text
按照 AI Engineering Kit V1.1.1 的
design-review Skill 审查当前 OpenSpec Change。

Change ID：
withdraw-online-amount-refactor

读取：

00-change-analysis.md
proposal
specs
design
tasks
相关 project-context
相关 rules
相关业务代码

只审查，不修改业务代码。

输出问题等级：

Blocker
High
Medium
Low

最终给出：

PASS
PASS_WITH_NON_BLOCKING_COMMENTS
BLOCKED
```

## 六、verification 调用示例

```text
按照 AI Engineering Kit V1.1.1 的
verification Skill 验证当前 Change。

Change ID：
withdraw-online-amount-refactor

检查：

Requirement Coverage
Design Conformance
Build
Test
Scenario
Compatibility

不得伪造未执行的验证结果。

输出：

openspec/changes/withdraw-online-amount-refactor/verification-report.md
```

## 七、change-review 调用示例

```text
按照 AI Engineering Kit V1.1.1 的
change-review Skill 审查当前 Change。

Change ID：
withdraw-online-amount-refactor

基于所有相关仓库实际 Diff。

重点检查：

遗漏修改
超范围修改
历史兼容
SQL
金额精度
事务
并发
锁
幂等
RPC
MQ
Job
日志
测试
文档同步

不要只做代码风格 Review。
```
