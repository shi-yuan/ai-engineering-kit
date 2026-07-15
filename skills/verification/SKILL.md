# verification

## 一、目标

验证实际实现：

1. 是否覆盖需求。
2. 是否符合已批准设计。
3. 是否完成必要工程验证。

## 二、输入

读取：

- 00-change-analysis.md
- proposal
- specs
- design
- tasks
- 实际代码
- 实际 Diff

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

## 四、Design Conformance

检查：

- 是否符合设计
- 是否绕过安全约束
- 是否增加未审批范围
- 是否遗漏多仓库修改
- 是否擅自修改接口语义
- 是否删除历史兼容逻辑

## 五、Build And Test

尽可能执行：

- 编译
- 单元测试
- 集成测试
- 静态检查

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

## 七、输出

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

最终结论：

```text
PASS
PASS_WITH_MANUAL_CHECKS
FAIL
BLOCKED
```
