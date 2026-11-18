# sql-review

项目接入模板占位文件。

实际执行 setup-agent 时，公共 Skill 会复制到：

```text
openspec/agent/skills/sql-review/SKILL.md
```

项目自定义 Skill（含存储口径、审计字段规范、数据库特性差异等）请放在：

```text
openspec/agent/custom-skills/sql-review/SKILL.md
```

setup-agent 不会覆盖 custom-skills；同名项目 Skill 优先于 Kit 通用骨架。
