# api-verification

项目接入模板占位文件。

实际执行 setup-agent 时，公共 Skill 会复制到：

```text
openspec/agent/skills/api-verification/SKILL.md
```

该 Skill 为通用骨架，要求项目在 `openspec/agent/custom-skills/api-verification/` 提供同名实例，
登记项目适配点（服务地址表、鉴权方式与凭证本地文件、统一响应判定、测试数据标记、环境前提、
输出目录）；适配点未登记前接口实测一律 BLOCKED。项目自定义 Skill 不会被 setup-agent 覆盖。

```text
openspec/agent/custom-skills/
```
