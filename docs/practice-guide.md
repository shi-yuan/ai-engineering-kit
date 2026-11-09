# 多仓历史项目实践指南

本文说明如何把 AI Engineering Kit 接入现有多仓大型项目，以及在日常需求中手动触发各阶段 Skill。

V1.2.0 默认采用：

```text
人工触发 Skill
+
人工 Review 阶段产物
+
人工决定是否进入下一阶段
+
Gate 治理
+
Context Sync
```

当前阶段不建议直接升级为自动 Workflow。先用 3 到 5 个中等复杂度历史需求把流程跑顺，再考虑增加 `workflow-state.yaml`、自动准入检查和自动阶段编排。

## 一、推荐项目目录

推荐从多仓聚合目录启动 Agent。

示例：

```text
xyy-pop/
├── AGENTS.md
├── .agent-env.md
├── CLAUDE.md
├── CODEBUDDY.md
├── CODEX.md
├── xyy-pop-core/
├── xyy-pop-business/
└── openspec/
    ├── config.yaml
    ├── agent/
    │   ├── project-rules.md
    │   └── skills/
    │       └── manifest.yaml
    ├── rules/
    ├── project-context/
    └── changes/
```

即使 OpenSpec 是独立 Git 仓库，也必须从外层聚合目录打开 Agent Workspace：

```text
xyy-pop/
```

不要只打开：

```text
xyy-pop/openspec/
```

否则 Agent 的搜索边界无法覆盖全部业务仓库。

## 二、运行 setup-agent

如果团队有多个业务项目，建议先阅读：

```text
docs/kit-discovery.md
```

并统一配置 `AI_ENGINEERING_KIT_HOME`，避免每个项目手工记忆 Kit 路径。

在 `ai-engineering-kit` 仓库执行脚本。

Windows PowerShell：

```powershell
cd E:\workspace\xiaoyy\sources\ai-engineering-kit

.\scripts\setup-agent.ps1 `
  -ProjectRoot E:\workspace\xyy-pop `
  -OpenSpecRepo E:\workspace\xyy-pop\openspec
```

Linux / macOS：

```bash
cd /path/to/ai-engineering-kit

./scripts/setup-agent.sh \
  /path/to/xyy-pop \
  /path/to/xyy-pop/openspec
```

参数含义：

| 参数 | 含义 |
|---|---|
| `ProjectRoot` | 多仓聚合目录，Agent 应该从这里启动 |
| `OpenSpecRepo` | OpenSpec 根目录，通常为 `<ProjectRoot>/openspec`；也兼容传入包含 `openspec/` 的父目录 |

执行后会在 `ProjectRoot` 下生成或更新：

```text
AGENTS.md
.agent-env.md
CLAUDE.md
CODEBUDDY.md
CODEX.md
openspec/agent/skills/
├── manifest.yaml
└── <skill-name>/SKILL.md
```

其中 `.agent-env.md` 应包含：

```text
AI_ENGINEERING_KIT_VERSION=1.2.0
AI_ENGINEERING_KIT_HOME=<ai-engineering-kit 仓库绝对路径>
WORKSPACE_ROOT=.
OPEN_SPEC_ROOT=<相对路径>/openspec
AGENT_SKILLS_ROOT=<相对路径>/openspec/agent/skills
```

## 三、做一个需求时如何执行

假设需求是：

```text
提现时优先扣减在线支付可提现金额，不足部分使用商户余额补充。
```

先定义 Change ID：

```text
withdraw-online-amount-refactor
```

### Agent 角色分配建议

不要按工具品牌强绑定阶段，而是按角色分配 Agent。

核心原则：

```text
分析 / 设计 / 实现 / Review 尽量分离
```

尤其是 Review 阶段，不建议让同一个上下文自己审自己。

| Step | 阶段 | 推荐角色 | 建议 Agent 使用方式 |
|---|---|---|---|
| 1 | `brownfield-analysis` | 分析型 Agent | 使用长上下文、全仓搜索能力较强的 Agent；只读分析，不写代码 |
| 2 | `OpenSpec propose` | 规格型 Agent | 基于 `00-change-analysis.md` 生成 proposal、spec delta、tasks |
| 3 | `change-design` | 设计型 Agent | 偏架构设计、边界收敛、兼容和回滚方案 |
| 4 | `design-review` | Review Agent | 最好换另一个 Agent 或新会话，不使用刚写 design 的上下文 |
| 5 | 人工 Review | 人 | 人工确认系统理解、影响范围、风险和方案 |
| 6 | `OpenSpec apply` | 编码型 Agent | 选择在当前代码库里改代码更稳定的 Agent |
| 7 | `verification` | 验证型 Agent | 实现 Agent 可先跑验证，再由另一个 Agent 复核报告 |
| 8 | `change-review` | Review Agent | 强烈建议换另一个 Agent 或新会话，基于真实 Diff 审查 |
| 9 | `context-sync` | 规格维护 Agent | 调用 context-sync Skill 沉淀长期事实；归档前需要人工确认 |
| 10 | `OpenSpec archive` | 规格维护 Agent | 在 verification、change-review、context-sync 通过后归档 |

如果团队主要使用 Claude Code 和 Codex，可以按以下方式起步：

```text
brownfield-analysis      Claude Code 或 Codex
OpenSpec propose         Claude Code
change-design            Claude Code
design-review            Codex 新会话
人工 Review              人
OpenSpec apply           Codex 或 Claude Code
verification             实现 Agent 先做，另一个 Agent 复核
change-review            另一个 Agent 或新会话
context-sync             Claude Code 或 Codex + 人工确认
OpenSpec archive         Claude Code 或 Codex
```

更重要的是角色隔离：

```text
写 design 的 Agent ≠ review design 的 Agent
写代码的 Agent ≠ review diff 的 Agent
```

如果只有一个 AI 工具，也至少使用新会话来做 `design-review` 和 `change-review`，并让它只读取必要事实：

```text
00-change-analysis.md
proposal
specs
design
tasks
verification-report.md
actual diff
```

不要把实现过程中的自我解释作为 Review 依据。

### Step 1：brownfield-analysis

对 Agent 发起：

```text
按照 AI Engineering Kit V1.2.0 的 brownfield-analysis Skill 分析当前需求。

Change ID：
withdraw-online-amount-refactor

需求：
提现时优先扣减在线支付可提现金额，不足部分使用商户余额补充。

要求：
1. 读取 AGENTS.md、.agent-env.md、OPEN_SPEC_ROOT/config.yaml。
2. 读取 OPEN_SPEC_ROOT/agent/project-rules.md、相关 rules、相关 project-context。
3. 以 WORKSPACE_ROOT 为代码搜索边界，分析所有相关仓库。
4. 只分析，不修改业务代码。
5. 输出到：
   openspec/changes/withdraw-online-amount-refactor/00-change-analysis.md
```

人工 Review `00-change-analysis.md`，重点确认：

- 需求理解是否正确。
- 业务入口是否完整。
- 主调用链和反向调用关系是否完整。
- 涉及仓库、模块、表、字段是否完整。
- RPC、MQ、Job、Redis、Apollo 是否检查。
- 事务、并发、锁、幂等、重试、补偿是否分析。
- 已确认事实、合理推断、待确认问题是否区分。

如果分析不完整，不进入下一阶段。

### Step 2：OpenSpec propose

在分析通过后，对 Agent 发起：

```text
基于当前需求和 openspec/changes/withdraw-online-amount-refactor/00-change-analysis.md，
创建 OpenSpec proposal、spec delta 和 tasks。

要求：
1. 不要重新猜测业务语义。
2. 必须引用 00-change-analysis.md 中的现状、影响范围和风险。
3. Proposal 必须覆盖涉及仓库、数据库、接口、RPC、MQ、Job、兼容性和风险。
4. Tasks 必须明确仓库、模块和验证方式，不得让实现 Agent 重新猜关键业务语义。
```

### Step 3：change-design

高风险 brownfield 需求建议保留独立设计产物。

适用场景：

- 多仓库修改。
- 涉及金额、余额、支付、提现、结算。
- 涉及状态机或历史数据兼容。
- 涉及 SQL 语义变化。
- 涉及 RPC、MQ、Job、Redis、Apollo。
- 涉及事务、并发、幂等、重试、补偿。

对 Agent 发起：

```text
基于 00-change-analysis.md、proposal、specs 和 tasks，完成当前 Change 的 design。

重点说明：
1. 当前行为。
2. 目标行为。
3. 最小安全变更方案。
4. 数据变化。
5. 调用链变化。
6. 事务、并发、幂等、重试、补偿。
7. 历史数据兼容。
8. 回滚方案。
9. Verification 策略。
```

低风险小改可以把 design 合并到 proposal 或 tasks 中，但必须保留以下设计信息：

```text
Implementation Design
Compatibility
Data Impact
Transaction / Idempotency
Rollback
Verification Plan
```

不要从 `00-change-analysis.md` 直接跳到代码实现。

### Step 4：design-review

对 Agent 发起：

```text
按照 design-review Skill 审查当前 OpenSpec Change。

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

最终结论使用：
PASS
PASS_WITH_NON_BLOCKING_COMMENTS
BLOCKED
```

存在 `BLOCKED` 时，不得进入实现。

### Step 5：人工 Review

人工重点确认：

- 系统理解是否正确。
- 影响范围是否完整。
- 设计是否过度或缺失。
- 兼容策略是否安全。
- 回滚方案是否可执行。
- Verification 策略是否覆盖主要风险。

人工确认后再进入实现。

### Step 6：OpenSpec apply

对 Agent 发起：

```text
按照已通过 Review 的 OpenSpec Change 实现代码。

Change ID：
withdraw-online-amount-refactor

严格依据：
00-change-analysis.md
proposal
specs
design
tasks

要求：
1. 不得擅自扩大范围。
2. 不得做无关重构。
3. 如果发现真实代码与 design 冲突，停止冲突部分并报告。
4. 不要自行修改设计语义后继续编码。
```

### Step 7：verification

对 Agent 发起：

```text
按照 verification Skill 验证当前 Change。

Change ID：
withdraw-online-amount-refactor

检查：
Requirement Coverage
Design Conformance
Build
Test
核心场景
边界场景
异常场景
重复请求
重复消费
重复 Job
并发
历史数据兼容

输出：
openspec/changes/withdraw-online-amount-refactor/verification-report.md

不得伪造未执行的验证结果。
```

未执行的检查必须说明原因、风险和后续动作。

### Step 8：change-review

对 Agent 发起：

```text
按照 change-review Skill 审查当前 Change。

Change ID：
withdraw-online-amount-refactor

基于所有相关仓库实际 Diff 审查。

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

最终结论使用：
PASS
PASS_WITH_NON_BLOCKING_COMMENTS
BLOCKED
```

`change-review` 的重点是看真实 Diff 是否符合已批准的分析和设计。它不是普通代码风格 Review。

### Step 9：context-sync

对 Agent 发起：

```text
按照 context-sync Skill 同步当前 Change 中已确认的长期系统事实和工程约束。

Change ID：
withdraw-online-amount-refactor

要求：
1. 只修改 OpenSpec 文档，不修改业务代码。
2. 长期系统事实进入 openspec/project-context/。
3. 长期工程约束进入 openspec/rules/。
4. 单次需求细节保留在 openspec/changes/<change-id>/。
5. 输出 openspec/changes/withdraw-online-amount-refactor/context-sync-report.md。
```

归档前先执行 Context Sync，检查：

```text
openspec/project-context/
openspec/rules/
openspec/project-context/integration/
openspec/project-context/runtime-config-template.md
```

如果这次需求沉淀出长期有效的系统事实，更新 `project-context`。

如果这次需求沉淀出长期有效的工程约束或业务约束，更新 `rules`。

单次需求细节保留在：

```text
openspec/changes/<change-id>/
```

不要污染长期规则和长期上下文。

如果存在 Context Drift，必须记录冲突并以真实代码分析当前行为；未确认推断不得进入长期上下文。

### Step 10：OpenSpec archive

只有在以下条件满足后才归档：

- Verification 通过，或人工接受剩余检查项并明确 Owner。
- Change Review 通过。
- Context Sync 已完成或明确无需同步。
- 阻塞问题已关闭。

## 四、openspec/rules 应放什么

`rules` 放长期有效、跨需求复用、对实现有约束力的规则。

判断标准：

```text
如果内容是“必须 / 禁止 / 应该怎么做”，放 rules。
```

推荐文件：

```text
openspec/rules/
├── change-gates.md
├── database.md
├── money.md
├── api-compatibility.md
├── dubbo.md
├── mq.md
├── job.md
├── redis-cache.md
├── transaction-consistency.md
├── logging-observability.md
├── testing.md
└── security-permission.md
```

### database.md

适合记录：

- 修改 SQL 条件时必须检查历史查询范围。
- 修改更新条件时必须检查是否承担并发控制职责。
- 大表查询必须检查索引、分页、排序和数据量级。
- 修改状态字段必须检查状态流转和历史数据。
- 涉及批量更新必须说明回滚和幂等策略。

### money.md

适合记录：

- 金额计算必须使用 `BigDecimal`。
- 禁止用 `double` / `float` 表示金额。
- `BigDecimal` 数值比较使用 `compareTo`。
- 修改金额语义时必须检查账单、支付、退款、结算、提现、对账。
- 涉及余额、额度、库存等核心数值时必须检查并发和幂等。

### api-compatibility.md

适合记录：

- 公共 DTO、枚举、接口字段不得随意删除或改变语义。
- 新增字段必须考虑老调用方兼容。
- 修改接口语义必须检查全部调用方。
- 对外接口必须考虑灰度期间新旧版本共存。

### dubbo.md

适合记录：

- 修改 Dubbo API、DTO、枚举时必须检查 Provider 和全部 Consumer。
- 修改超时、重试配置必须分析幂等影响。
- 不得只修改调用方或实现方后结束分析。
- 接口兼容策略必须在 design 中说明。

### mq.md

适合记录：

- 修改 Topic、Tag、消息体字段或消息语义时，必须检查 Producer 和全部 Consumer。
- Consumer 必须考虑重复消费。
- 修改消息体时必须考虑历史消息兼容。
- 不得假设消息只会被消费一次。

### job.md

适合记录：

- 修改定时任务必须检查重复执行。
- 修改补偿、对账、修复任务必须检查与实时链路的一致性。
- 批处理任务必须检查分页、游标、排序稳定性和中断恢复。

### redis-cache.md

适合记录：

- 修改 Redis Key 必须说明 Key 维度、过期时间和兼容影响。
- 修改缓存语义必须检查读写双方。
- 涉及分布式锁必须检查锁范围、过期时间、异常释放和事务边界。

### transaction-consistency.md

适合记录：

- 涉及资金、余额、库存、额度变更时必须明确事务边界。
- 跨库、RPC、MQ 场景必须说明最终一致性策略。
- 涉及重试、补偿、Job 时必须保证幂等。
- 状态机修改必须说明合法状态流转。

### logging-observability.md

适合记录：

- 关键状态变化必须有可追踪日志。
- 资金、订单、支付、提现等链路必须记录业务主键。
- 异常吞掉或降级必须说明监控和告警方式。

### testing.md

适合记录：

- 高风险变更必须补充 characterization tests 或回归用例。
- 测试必须覆盖正常、边界、异常、重复、并发或历史数据场景。
- 无法执行测试必须在 verification-report 中说明原因和风险。

### security-permission.md

适合记录：

- 修改权限、角色、租户、数据范围时必须检查越权风险。
- 修改后台操作入口必须检查审计日志。
- 修改用户可见数据必须检查脱敏和访问控制。

## 五、openspec/project-context 应放什么

`project-context` 放长期有效的系统事实。

判断标准：

```text
如果内容是“当前系统是什么样”，放 project-context。
```

推荐文件：

```text
openspec/project-context/
├── system-overview.md
├── architecture.md
├── module-map.md
├── data-model.md
├── integration-map.md
├── runtime-config.md
├── deployment.md
├── repositories/
│   ├── xyy-pop-core.md
│   ├── xyy-pop-business.md
│   ├── xyy-pop-api.md
│   └── xyy-pop-job.md
└── business/
    ├── payment-flow.md
    ├── order-flow.md
    ├── settlement-flow.md
    ├── withdraw-flow.md
    ├── refund-flow.md
    └── business-invariants.md
```

### system-overview.md

记录：

- 系统定位。
- 核心业务域。
- 主要用户和外部系统。
- 核心业务链路。
- 高风险业务域。

### architecture.md

记录：

- 总体架构分层。
- Web / API / Service / Domain / Mapper 关系。
- Dubbo Provider / Consumer 分布。
- MQ Producer / Consumer 分布。
- Job、补偿、对账、修复链路。
- Redis、Apollo、Cache 的使用边界。

### module-map.md

记录：

| 仓库 | 模块 | 职责 | 主要依赖 |
|---|---|---|---|
| xyy-pop-api | API / DTO | 对外接口定义 | core, business |
| xyy-pop-core | 核心服务 | 订单、支付、提现核心逻辑 | MySQL, Redis |
| xyy-pop-job | 定时任务 | 对账、补偿、修复 | MQ, DB |

### data-model.md

记录核心表和字段语义，不要求替代完整数据库文档。

建议包含：

- 核心表。
- 业务主键。
- 状态字段。
- 金额字段。
- 关键索引。
- 历史数据兼容说明。

示例：

| 表 | 作用 | 关键字段 | 状态字段 | 金额字段 |
|---|---|---|---|---|
| withdraw_order | 提现单 | withdraw_no, merchant_id | status | amount |

### integration-map.md

记录跨进程、异步、外部系统关系。

| 类型 | 调用方 / Producer | 被调用方 / Consumer | 用途 |
|---|---|---|---|
| Dubbo | xyy-pop-business | xyy-pop-core | 查询商户余额 |
| MQ | payment-service | bill-service | 支付成功后生成账单 |
| Job | xyy-pop-job | withdraw_order | 提现补偿 |

### runtime-config.md

记录：

- 关键 Apollo 配置。
- 配置默认值。
- 配置动态刷新语义。
- 配置缺失时的系统行为。
- 关键开关和灰度策略。

### deployment.md

记录：

- 服务部署关系。
- 环境差异。
- 关键中间件依赖。
- 上线顺序约束。
- 回滚注意事项。

### repositories/*.md

每个仓库一份，记录：

- 仓库职责。
- 主要模块。
- 技术栈。
- 对外接口。
- 主要依赖。
- 高风险修改点。

### business/*.md

每个核心业务域一份，记录：

- 业务流程。
- 状态流转。
- 关键表。
- 关键接口。
- 关键 MQ / Job。
- 异常和补偿流程。
- 历史兼容逻辑。

### business/business-invariants.md

这是非常关键的长期上下文，记录跨需求长期有效、容易被误解且会影响实现正确性的业务不变量。

示例：

| ID | 业务域 | 不变量 | 原因 | 代码证据 |
|---|---|---|---|---|
| INV-WITHDRAW-001 | 提现 | 提现成功后金额不可再次扣减 | 防止重复扣款 | XxxService#confirm |
| INV-BILL-001 | 账单 | 已结算账单不能修改金额 | 保证结算一致性 | BillStatus.SETTLED |

## 六、OPEN_SPEC_ROOT/agent/project-rules.md 应放什么

`project-rules.md` 放当前项目总体工程规则，是 Agent 进入项目后的项目级约束入口。

它不应该复制所有通用 Skill 流程，也不应该记录单次需求细节。

推荐结构：

```text
OPEN_SPEC_ROOT/agent/project-rules.md
```

建议包含：

```markdown
# Project Rules

## 1. 项目技术基线

- Java 8
- Spring Boot
- MyBatis
- MySQL
- Redis
- RocketMQ
- Apollo
- Dubbo

## 2. Workspace 规则

- 必须从多仓聚合目录启动 Agent。
- 代码搜索边界为 WORKSPACE_ROOT。
- OpenSpec Root 由 OPEN_SPEC_ROOT 指定。
- 不得只分析 OpenSpec 仓库。

## 3. 项目模块关系

- xyy-pop-api：接口、DTO、枚举。
- xyy-pop-core：核心领域服务。
- xyy-pop-business：业务编排。
- xyy-pop-job：定时、补偿、对账任务。

## 4. 项目工程约束

- 必须保持 Java 8 兼容。
- 修改公共 DTO、API、枚举时必须搜索全部使用方。
- 修改 Mapper 或 SQL 时必须检查索引、分页、NULL 语义和更新条件。
- 金额处理必须检查 BigDecimal 精度和比较方式。
- 资金状态变化必须检查事务、并发、幂等和补偿。
- Dubbo 接口修改必须分析 Provider 和 Consumer 兼容性。
- MQ 修改必须分析 Producer、Consumer、重复消费和历史消息兼容。
- Job 修改必须分析重复执行和补偿链路。
- Apollo 配置修改必须说明默认值和未配置环境行为。

## 5. 项目特殊约束

- 修改支付状态时必须检查支付、退款和对账链路。
- 修改账单金额语义时必须检查结算、提现和补偿任务。
- 修改提现逻辑时必须检查余额、冻结金额、补偿 Job 和对账。

## 6. 文档沉淀规则

- 长期系统事实进入 openspec/project-context/。
- 长期工程或业务约束进入 openspec/rules/。
- 单次需求细节只保留在 openspec/changes/<change-id>/。
```

## 七、不要放错位置

不要把单次需求细节放进 `rules` 或长期 `project-context`。

这些内容应该放在 `openspec/changes/<change-id>/`：

- 本次需求要新增某字段。
- 本次临时灰度方案。
- 本次 change 的具体实现步骤。
- 某次上线前临时开关。
- 某个 Agent 当次分析过程。

这些内容才适合长期沉淀：

- 某个状态长期不可逆。
- 某个金额字段的长期业务语义。
- 某个 MQ 消息必须幂等消费。
- 某个补偿 Job 与实时链路的长期关系。
- 某个仓库长期承担的系统职责。

## 八、最小起步清单

如果首次接入不想一次写太多，至少准备：

```text
OPEN_SPEC_ROOT/agent/project-rules.md

openspec/rules/
├── database.md
├── money.md
├── dubbo.md
├── mq.md
├── transaction-consistency.md
└── testing.md

openspec/project-context/
├── system-overview.md
├── architecture.md
├── module-map.md
├── data-model.md
└── business/
    └── business-invariants.md
```

这套最小清单已经能明显提高 brownfield-analysis 的质量。

核心原则：

```text
rules 管约束
project-context 管事实
changes/<change-id> 管单次变更
```
## 九、实践注意事项

### 1. 先选中等复杂度需求试点

首次落地不要选择最简单的新功能，也不要选择最高风险的资金核心链路。

推荐选择：

- 涉及 2 到 3 个仓库。
- 有数据库读写。
- 有少量 RPC、MQ 或 Job 影响。
- 有明确人工验收标准。
- 线上风险可控。

目标是验证流程是否能减少返工，而不是一次性证明所有复杂场景。

### 2. Change ID 要稳定、可读、可追踪

Change ID 会进入 `openspec/changes/<change-id>/`，也会出现在分析、设计、验证和 Review 产物中。

建议格式：

```text
<domain>-<behavior>-<action>
```

示例：

```text
xyy-pop/
├── AGENTS.md
├── .agent-env.md
├── CLAUDE.md
├── CODEBUDDY.md
├── CODEX.md
├── xyy-pop-core/
├── xyy-pop-business/
└── openspec/
    ├── config.yaml
    ├── agent/
    │   ├── project-rules.md
    │   └── skills/
    │       └── manifest.yaml
    ├── rules/
    ├── project-context/
    └── changes/
```

不要使用：

```text
test
change1
fix-bug
需求123
```

### 3. 开始前确认工作区状态

执行需求前建议确认：

- 当前分支是否正确。
- 是否存在未提交的人工改动。
- 多仓库是否都在预期分支。
- OpenSpec 仓库和业务代码仓库是否同步到正确基线。

如果工作区已有无关改动，必须在 `00-change-analysis.md` 或人工记录中说明，避免 change-review 误判 Diff。

### 4. brownfield-analysis 必须有代码证据

`00-change-analysis.md` 中的重要结论应尽量带证据，例如：

- 仓库 / 文件 / 类 / 方法。
- 表 / 字段 / SQL。
- RPC Provider / Consumer。
- MQ Producer / Consumer。
- Job 名称和触发方式。
- 配置 Key。

不要接受只有概括性描述、没有证据索引的分析产物。

### 5. 待确认问题要分级

不是所有待确认问题都会阻塞下一阶段。

建议分为：

| 类型 | 处理方式 |
|---|---|
| 阻塞问题 | 不进入 propose / design / apply，必须人工确认 |
| 非阻塞问题 | 可以进入下一阶段，但必须记录风险和 Owner |
| 可通过代码继续调查的问题 | 不应丢给人工，Agent 应继续搜索 |

凡是影响需求正确性、数据安全、兼容性、回滚的问题，都按阻塞问题处理。

### 6. 控制变更范围

历史项目修改默认采用最小安全变更。

禁止在同一个 Change 中混入：

- 无关重构。
- 顺手格式化大量文件。
- 顺手升级依赖。
- 顺手改命名。
- 顺手修不相关 Bug。

如果实现中发现必须扩大范围，应停止扩大实现，回到 design 阶段更新 artifact 并重新 Review。

### 7. 设计可以轻量，但不能消失

低风险小改可以不单独维护复杂 `design.md`，但必须在 proposal 或 tasks 中保留设计信息：

```text
Implementation Design
Compatibility
Data Impact
Transaction / Idempotency
Rollback
Verification Plan
```

高风险 brownfield 需求必须保留独立设计产物。

### 8. 测试不足时先补现状锁定测试

历史项目经常测试不足。此时不要只依赖 AI 的代码解释。

优先补充 characterization tests，用来锁定当前行为：

```text
先证明旧行为是什么
再证明新行为只改变目标 Delta
```

如果无法补自动化测试，必须在 `verification-report.md` 中记录：

- 未执行原因。
- 风险影响。
- 人工验证方式。
- 后续补测计划。

### 9. 多仓 Diff 必须统一审查

多仓项目不能只审查当前 Agent 打开的仓库。

`change-review` 前必须收集所有相关仓库 Diff，并对比：

- `00-change-analysis.md` 中确定受影响仓库。
- design 中声明的修改范围。
- 实际发生修改的仓库。

出现未声明仓库修改或声明仓库未修改，都必须解释原因。

### 10. 关注灰度、回滚和兼容

历史系统修改不能只考虑代码合并成功。

设计和验证阶段需要明确：

- 新旧逻辑是否会共存。
- 老接口、老 Consumer、历史消息是否兼容。
- 历史数据是否需要迁移或兜底。
- 配置未开启时行为是什么。
- 回滚后新数据是否会影响旧代码。

### 11. 不要把 Agent 输出当事实

Agent 的分析结论只有在有代码、配置、文档或测试证据支撑时才是事实。

产物中必须区分：

```text
已确认事实
合理推断
待确认问题
```

人工 Review 时重点检查 Agent 是否把推断写成了事实。

### 12. 人工 Review 要看门禁，不只看文字

人工 Review 不只是读一遍文档。

建议至少检查：

- 本阶段必须产物是否存在。
- 结论枚举是否允许进入下一阶段。
- Blocker 是否关闭。
- 待确认问题是否有 Owner。
- Verification 是否真实执行。
- Diff 是否超出设计范围。

没有通过门禁时，不要因为“代码看起来能跑”就进入下一阶段。

### 13. 敏感信息不要写入 artifacts

OpenSpec artifacts 可能长期保存，也可能被多个 Agent 读取。

不要写入：

- 密码、Token、密钥。
- 生产数据库连接串。
- 用户隐私数据。
- 原始订单、手机号、身份证等敏感样本。

需要举例时使用脱敏数据。

### 14. 每次归档都要沉淀长期知识

`archive` 前至少问一次：

```text
这次需求是否发现了长期有效的系统事实？
这次需求是否发现了以后必须遵守的工程或业务约束？
```

如果是系统事实，进入：

```text
openspec/project-context/
```

如果是约束规则，进入：

```text
openspec/rules/
```

如果只是本次需求细节，保留在：

```text
openspec/changes/<change-id>/
```

### 15. 定期复盘流程本身

每跑完几个需求，建议复盘：

- 哪些 checklist 经常漏。
- 哪些 rules 缺失导致返工。
- 哪些 project-context 已过期。
- 哪些 Review 问题可以前移到 design-review。
- 哪些手工检查已经稳定，可以未来自动化。

只有当人工流程稳定后，再升级自动 Workflow。
