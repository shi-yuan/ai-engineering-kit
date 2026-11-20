# 变更 Gate 规则

## 目的

本文定义大型历史复杂业务系统的 AI 辅助开发 Gate，用于防止 Agent 在系统理解不完整时过早编码，防止 Requirement、Analysis、Proposal、Design、Tasks、Implementation、Verification、Review 之间失真。

任何非全新功能变更都应按 Gate 推进。Gate 未通过时，不得进入下一阶段；如需豁免，必须由人工明确记录原因、风险和 Owner。

## 需求分类

| 类型 | 适用场景 | 推荐流程 |
|---|---|---|
| A 全新独立功能 | 与历史状态、历史接口、历史数据、异步链路基本无耦合 | 可简化分析，但仍需 Proposal、Design、Tasks、Verification |
| B 历史功能增强 | 修改既有接口、流程、表、状态、消息、任务或兼容逻辑 | 必须完整执行 Gate 0-8 及人工 Code Review |
| C 高风险核心变更 | 涉及资金、库存、履约、授信、结算、权限、计费、合同、法务合规等高风险领域 | 在 B 基础上增加人工关键事实确认、架构 Review、业务 Review、上线风险清单 |

## Gate 0：上下文加载

通过条件：

- 已读取项目聚合目录 `AGENTS.md`。
- 已读取 `.agent-env.md` 并确认 `AI_ENGINEERING_KIT_HOME`、`WORKSPACE_ROOT`、`OPEN_SPEC_ROOT`、`AGENT_SKILLS_ROOT`。
- 已读取 `OPEN_SPEC_ROOT/config.yaml`。
- 已读取 `OPEN_SPEC_ROOT/agent/project-rules.md`。
- 已读取相关 `OPEN_SPEC_ROOT/rules/*.md`。
- 已读取相关 `OPEN_SPEC_ROOT/project-context/*.md`。
- 已确认代码搜索和影响分析边界是 `WORKSPACE_ROOT`，不是单个模块或单个 OpenSpec 仓库。

禁止通过：

- 未确认 Workspace 边界。
- 只分析 OpenSpec 仓库，不分析业务代码。
- 忽略 project-context 中已沉淀的不变量、集成清单或历史约束。

## Gate 1：Brownfield Analysis

通过条件：

- 历史功能修改已完成 `OPEN_SPEC_ROOT/changes/<change-id>/00-change-analysis.md`。
- 已区分已确认事实、合理推断、待确认问题。
- 已覆盖业务入口、调用链、反向调用关系、数据流、状态变化、历史兼容逻辑。
- 已覆盖数据库、RPC、MQ、Job、Redis、配置、Cache、外部系统和上下游影响。
- 涉及高风险核心业务时，已写清关键业务不变量、状态保护、金额/数量/权限边界、幂等键和失败收敛路径。
- 关键结论均有代码、配置、DDL、运行态信息或已确认文档证据。

禁止通过：

- 只搜索少量代码后直接提出方案。
- 用类名、方法名、字段名替代业务事实。
- 把单个 SQL 或局部代码推断出的语义写成已确认事实。
- 待确认问题会影响方案但未标明阻塞程度。

## Gate 2：Proposal

通过条件：

- Proposal 的背景和目标能追溯到原始需求与 `00-change-analysis.md`。
- Proposal 明确非目标。
- Proposal 明确涉及模块、仓库、数据库、接口、RPC、MQ、Job、事务、幂等、兼容性和风险。
- Proposal 未把推断写成已确认事实。

禁止通过：

- Proposal 发明项目中不存在的表、服务、消息、任务或架构层。
- Proposal 忽略已知业务不变量。
- Proposal 范围超过需求且无明确理由。

## Gate 3：Design

通过条件：

- Design 每个关键决策都能追溯到 Requirement、Proposal 或 `00-change-analysis.md`。
- Design 写清状态机、幂等键、事务边界、失败补偿、灰度和回滚。
- Design 写清 API/RPC/MQ/DB 兼容策略。
- Design 写清对管理端、报表、对账、Job、回调、补偿或下游系统的影响。
- 依赖运行态配置、外部系统能力或生产数据分布时，已标注证据或待确认项。

禁止通过：

- Design 只描述代码结构，不描述业务状态和一致性。
- Design 改变业务不变量但未显式说明。
- Design 依赖未确认运行态配置作为事实。

## Gate 4：Tasks

通过条件：

- Tasks 覆盖 Design 的全部实现点和验证点。
- 每个 Task 有明确输入、输出、涉及模块和依赖关系。
- 跨模块/跨仓修改明确对应仓库。
- 包含 Verification Task 和必要的文档同步 Task。

禁止通过：

- Task 要求实现 Agent 重新猜测业务语义。
- Task 粒度过大，无法在 Review 中判断完成情况。
- Task 遗漏数据库、RPC、MQ、Job、回调、补偿、报表或测试中的任一已知影响。

## Gate 5：Implementation

通过条件：

- 实现严格对应已 Review 的 Tasks 和 Design。
- 未进行无关重构。
- 未改变未授权的 API、状态机、金额单位、数量单位、权限语义、幂等语义。
- 关键写操作（保存/修改/删除/状态变更/审批等）已按 `rules/logging-observability.md` 记录日志，属于实现完成的一部分。
- 发现代码事实与 Design 冲突时，已停止冲突部分并回到设计阶段。

禁止通过：

- 为了实现方便扩大需求范围。
- 删除历史兼容逻辑。
- 绕过枚举、状态转换方法、领域服务或一致性保护直接硬编码新行为。
- 关键写操作缺失日志，留到 Review 阶段再补。
- 修改公共 API、消息体、表结构或状态语义但未更新 Proposal/Design。

## Gate 6：Verification

通过条件：

- 验证覆盖 Requirement、Design、Tasks 和已识别风险。
- 编译、测试、SQL、RPC、MQ、Job、联调或人工检查结果真实记录。
- 需要真实容器语义（鉴权、序列化、实际 SQL、中间件联动、跨服务链路）的验证项，优先走
  `api-verification` 接口实测（项目须在 custom-skills 提供同名实例登记适配点后启用），
  其产物并入本 Gate 证据；无法实测的列为人工检查项。
- 无法执行的验证项已说明原因、剩余风险和 Owner。
- 至少覆盖正常、重复、异常、并发、补偿、历史数据兼容中与本次变更相关的场景。

禁止通过：

- 伪造测试结果。
- 只验证 happy path。
- 高风险核心变更未验证幂等、状态保护和失败收敛。
- MQ/Job 变更未验证重复消费或重复执行语义。

## Gate 7：Change Review

通过条件：

- Review 检查代码是否符合 Design。
- Review 检查 Design 是否仍符合 Proposal。
- Review 检查实现是否仅覆盖 Tasks。
- Review 基于真实 Diff、代码、配置和验证结果，不以实现 Agent 的自述作为唯一证据。
- Review 列出残余风险、未验证项和人工确认项。

禁止通过：

- 只总结改了什么，不检查行为风险。
- 不处理 Design 与代码事实的偏差。
- 对未验证生产配置、外部依赖或历史数据风险保持沉默。

## 人工 Code Review

Gate 7 通过后、Gate 8 前的人工节点。Gate 7 审查设计与业务风险的一致性，本节点审查代码层质量与需求覆盖。

执行方式：

- 人工调用 `code-review`（项目 custom-skills 同名 Skill 优先，缺失时回退 Kit 通用骨架）。
- 变更涉及 DDL（diff 出现 DDL 脚本，或 Proposal 声明数据库影响非空）时，先人工调用 `sql-review`，报告并入 `code-review.md`。
- 报告落盘 `OPEN_SPEC_ROOT/changes/<change-id>/code-review.md`。

通过条件：

- P0 全部修复或经人工确认接受。
- 需求覆盖矩阵无"未覆盖"项，或遗漏项已补充实现。
- 涉及 DDL 时 `sql-review` P0 已清零且回滚脚本齐备。
- 结论为 `PASS` 或 `PASS_WITH_NON_BLOCKING_COMMENTS`。

禁止通过：

- 存在未修复且未经人工确认的 P0。
- 需求覆盖矩阵存在"未覆盖"项且未补充实现。
- A 类变更豁免时未在 `code-review.md` 记录豁免原因和 Owner。

豁免规则：A 类全新独立功能可经人工豁免（须记录）；B/C 类变更不得豁免。

## Gate 8：Context Sync

通过条件：

- 已判断是否需要更新 `OPEN_SPEC_ROOT/project-context/`。
- 已判断是否需要更新 `OPEN_SPEC_ROOT/rules/`。
- 已判断是否需要更新集成注册表、运行态配置清单、业务不变量和模块地图。
- 长期系统知识进入 project-context 或 rules。
- 单次需求细节留在 change artifacts。
- Agent handoff 已记录当前状态、残余风险和下一步。

禁止通过：

- 把单次需求细节污染长期规则。
- 把可复用系统事实只留在临时 change。
- 归档前未处理 Context Drift。
- Agent handoff 未记录当前状态。

## Gate 失败处理

任一 Gate 失败时：

1. 停止进入下一阶段。
2. 记录失败原因和阻塞程度。
3. 补齐缺失证据或回到上一阶段。
4. 如需人工确认，明确问题、风险、确认对象和 Owner。
