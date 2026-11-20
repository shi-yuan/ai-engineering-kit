# verification

## 一、目标

验证实际实现：

1. 是否覆盖需求。
2. 是否符合已批准设计。
3. 是否完成必要工程验证。

本 Skill 对应：

```text
Gate 6 Verification
```

## 二、输入

读取：

- 00-change-analysis.md
- proposal
- specs
- design
- tasks
- 实际代码
- 实际 Diff
- `openspec/rules/change-gates.md`
- `openspec/project-context/agent-handoff.md`

## 三、Requirement Coverage

建立映射：

```text
Requirement
↓
Design
↓
Task
↓
Code
↓
Test / Verification
```

检查：

- Requirement 是否有 Design
- Design 是否有 Task
- Task 是否有 Code
- Code 是否有验证
- 验证是否覆盖 `00-change-analysis.md` 中识别的风险

## 四、Design Conformance

检查：

- 是否符合设计
- 是否绕过安全约束
- 是否增加未审批范围
- 是否遗漏多仓库修改
- 是否擅自修改接口语义
- 是否删除历史兼容逻辑
- 是否实现了未经 Review 的推断或临时规则
- 是否出现 Design Drift 或 Context Drift

## 五、Build And Test

尽可能执行：

- 编译
- 单元测试
- 集成测试
- 静态检查
- SQL/DDL 验证
- RPC/MQ/Job 相关验证
- 需要真实容器语义（鉴权、序列化、实际 SQL、中间件联动、跨服务链路）的验证项，
  优先走 `api-verification` 接口实测（项目须已提供 custom-skills 同名实例登记适配点）

不得伪造结果。

无法执行必须明确说明：

- 未执行项目
- 原因
- 风险

## 六、Scenario Verification

检查：

- 正常场景
- 边界场景
- 异常场景
- 重复请求
- 重复消费
- 重复 Job
- 并发
- 历史数据
- 配置缺失
- 外部系统异常
- 补偿收敛

同时检查日志与可观测性（对照 `openspec/rules/logging-observability.md`）：

- 本次变更新增/修改的写操作入口与结果是否有日志（含业务主键/单号）。
- 核心场景能否通过日志还原操作轨迹；异常场景能否通过日志定位失败阶段。

## 七、Context Sync Check

检查是否产生需要沉淀的长期知识：

- 新业务不变量。
- 新模块职责或调用链。
- 新表、字段、状态、业务键。
- 新 RPC/MQ/Job/外部系统事实。
- 新运行态配置。
- 新工程规则。

本阶段只判断是否需要同步；实际同步可在 Gate 8 完成。

## 八、输出

输出：

```text
openspec/changes/<change-id>/verification-report.md
```

报告至少包含：

- Requirement Coverage
- Design Conformance
- Build Result
- Test Result
- Scenario Result
- Known Risk
- Unverified Items
- Context Sync Items
- Handoff Notes

最终结论：

```text
PASS
PASS_WITH_MANUAL_CHECKS
FAIL
BLOCKED
```
