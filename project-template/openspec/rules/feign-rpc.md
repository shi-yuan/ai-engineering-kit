# RPC / Feign 规则

## 适用范围

修改 Spring Cloud OpenFeign Client、FallbackFactory、RPC DTO、枚举、
超时/重试/降级配置、返回语义时适用。
Dubbo 项目使用 `dubbo.md`；本项目 RPC 栈以 `agent/project-rules.md` 技术基线为准。

## 必须检查

- Client 接口定义和全部调用方。
- 对应 FallbackFactory 的降级行为是否满足调用方预期。
- RPC DTO 新增字段、删除字段、默认值、空值兼容（调用方与实现方两端）。
- 枚举新增、删除、重命名和老调用方处理。
- 错误码、返回包装（如 `R<T>`）语义变化。
- 幂等性是否能承受超时重试。
- 跨模块/跨仓库修改是否完整（Feign Client 常按模块拆分仓库）。

## 禁止事项

- 不得只修改 Client 定义或只修改实现方后结束分析。
- 不得删除公共字段或改变字段语义而不提供兼容方案。
- 不得把 Feign 超时等同于业务失败；超时后必须按幂等语义查询确认。
- 不得在未确认幂等的情况下开启重试。
- 不得绕过统一响应解包工具直接解析原始响应。

## Design 要求

涉及 RPC 时必须说明：

- API 兼容策略。
- 调用方/实现方影响范围（含跨仓库）。
- 降级路径（FallbackFactory 行为变化）。
- 超时、重试和幂等策略。
- Workspace 外调用方待确认项。

## Verification 要求

- 至少验证老入参、老返回兼容。
- 涉及重试/降级时验证重复请求语义与 Fallback 行为。
- 无法联调时记录未验证风险和 Owner。
