# MQ 规则

## 适用范围

修改 Topic、Tag、Producer、Consumer、Consumer Group、消息体、消息语义、重试、死信、顺序、延迟消息时适用。

## 必须检查

- Producer 和全部 Consumer。
- Consumer Group 和订阅 Tag。
- 消息体字段、序列化格式、老消息兼容。
- 重复消费、乱序、延迟、重试、死信。
- 事务提交与消息发送顺序。
- 消费失败后的补偿路径。
- Workspace 外消费者是否存在。

## 禁止事项

- 不得假设消息只会被消费一次。
- 不得删除消息字段或改变字段语义而不兼容老消息。
- 不得让 Consumer 在无幂等保护时执行高风险副作用。
- 不得忽略消息重试导致状态被旧消息覆盖。

## Design 要求

涉及 MQ 时必须说明：

- Topic、Tag、Producer、Consumer、Group。
- 消息体变化和兼容策略。
- 幂等键。
- 重试和死信处理。
- 与本地事务的一致性策略。

## Verification 要求

- 验证重复消费。
- 验证老消息兼容。
- 验证失败重试或补偿路径。
- 无法连接 MQ 环境时记录人工检查项。
