# RPC / Dubbo 规则

## 适用范围

修改 RPC/Dubbo API、DTO、枚举、Provider、Consumer、调用配置、超时、重试、异常语义时适用。

## 必须检查

- Provider 和全部 Consumer。
- Workspace 外调用方是否存在。
- version、group、timeout、retry、sent、check 等配置。
- DTO 新增字段、删除字段、默认值、空值兼容。
- 枚举新增、删除、重命名和老调用方处理。
- 异常码、错误码、返回语义变化。
- 幂等性是否能承受 RPC 超时重试。

## 禁止事项

- 不得只修改 Provider 或只修改 Consumer 后结束分析。
- 不得删除公共字段或改变字段语义而不提供兼容方案。
- 不得把 RPC 超时等同于业务失败。
- 不得在未确认幂等的情况下增加重试。

## Design 要求

涉及 RPC 时必须说明：

- API 兼容策略。
- Provider/Consumer 影响范围。
- 灰度期间新旧版本共存方式。
- 超时、重试和幂等策略。
- Workspace 外调用方待确认项。

## Verification 要求

- 至少验证老入参、老返回兼容。
- 涉及重试时验证重复请求语义。
- 无法联调时记录未验证风险和 Owner。
