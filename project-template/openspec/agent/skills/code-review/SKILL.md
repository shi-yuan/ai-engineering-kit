# code-review

项目接入模板占位文件。

实际执行 setup-agent 时，公共 Skill 会复制到：

```text
openspec/agent/skills/code-review/SKILL.md
```

项目自定义 Skill（含业务红线、分层规范、模块差异等）请放在：

```text
openspec/agent/custom-skills/code-review/SKILL.md
```

setup-agent 不会覆盖 custom-skills；同名项目 Skill 优先于 Kit 通用骨架。
