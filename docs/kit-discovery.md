# Kit Discovery 与 Skill Resolution

当一个团队同时接入多个大型业务项目时，不应依赖人工记忆 `ai-engineering-kit` 的绝对路径。

本机制解决两个问题：

```text
Kit Discovery：如何找到 AI Engineering Kit 根目录
Skill Resolution：执行某个 Skill 时，从哪里读取 Skill 定义
```

它不改变 V1.1.1 的人工触发流程，也不引入自动 Workflow。

## 一、推荐配置

建议在开发机或 CI 环境设置：

```text
AI_ENGINEERING_KIT_HOME=<ai-engineering-kit 仓库绝对路径>
```

Windows PowerShell 示例：

```powershell
[Environment]::SetEnvironmentVariable(
  "AI_ENGINEERING_KIT_HOME",
  "E:\workspace\xiaoyy\sources\ai-engineering-kit",
  "User"
)
```

Linux / macOS 示例：

```bash
export AI_ENGINEERING_KIT_HOME=/path/to/ai-engineering-kit
```

业务项目执行 `setup-agent` 后，生成的 `.agent-env.md` 也会记录：

```text
AI_ENGINEERING_KIT_HOME=<kit-root>
AGENT_SKILLS_ROOT=<OPEN_SPEC_ROOT>/agent/skills
```

其中 `AGENT_SKILLS_ROOT` 下应包含：

```text
manifest.yaml
<skill-name>/SKILL.md
```

## 二、Kit Discovery 顺序

工具或 Agent 需要定位 Kit 时，按以下顺序查找：

1. 当前环境变量 `AI_ENGINEERING_KIT_HOME`。
2. 当前业务项目 `.agent-env.md` 中的 `AI_ENGINEERING_KIT_HOME`。
3. 从当前目录向上查找是否存在 Kit 根目录特征文件。

有效 Kit 根目录必须同时包含：

```text
VERSION
AGENTS.base.md
skills/
scripts/
```

## 三、Skill Resolution 顺序

执行 Skill 时，优先读取项目 Skill 清单：

```text
<ProjectRoot>/<OPEN_SPEC_ROOT>/agent/skills/manifest.yaml
```

根据 `manifest.yaml` 中的 `name` 和 `entry` 定位：

```text
<ProjectRoot>/<OPEN_SPEC_ROOT>/agent/skills/<skill-name>/SKILL.md
```

如果项目清单中没有该 Skill，再回退到公共 Kit 清单：

```text
$AI_ENGINEERING_KIT_HOME/skills/manifest.yaml
$AI_ENGINEERING_KIT_HOME/skills/<skill-name>/SKILL.md
```

只有在 `manifest.yaml` 缺失时，才回退到目录约定 `<skill-name>/SKILL.md`。

推荐默认使用项目 OpenSpec 内复制的 Skill 清单，因为它与业务项目接入时的 Kit 版本一致，更利于复现。

项目可以在 `openspec/agent/skills/manifest.yaml` 中增加项目私有 Skill，例如：

```yaml
skills:
  - name: project-domain-analysis
    entry: project-domain-analysis/SKILL.md
    description: 当前项目特有的领域分析 Skill。
    phase: analysis
    modifies_code: false
```

`modifies_code` 表示该 Skill 是否允许修改业务代码：

| 值 | 含义 |
|---|---|
| `false` | 只读分析、审查或验证，不应修改业务代码 |
| `true` | 允许修改业务代码，必须配合明确的阶段门禁和人工授权 |

如果项目清单中声明了与公共 Kit 同名的 Skill，项目清单优先。这适合项目级定制，但应谨慎使用，并在 `description` 中说明差异。

## 四、辅助脚本

发现 Kit 根目录：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\discover-kit.ps1
```

解析业务项目中的 Skill：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\resolve-skill.ps1 `
  -ProjectRoot E:\workspace\xyy-pop `
  -Skill brownfield-analysis
```

输出的是实际应该读取的 `SKILL.md` 路径。

## 五、实践建议

- 多个业务项目共用同一个 `AI_ENGINEERING_KIT_HOME`。
- 每个业务项目通过 `setup-agent` 复制一份 `openspec/agent/skills`，包含 `manifest.yaml` 和 Skill 目录，形成项目级 Skill 快照。
- 升级 Kit 后，重新执行 `setup-agent`，不要手工复制单个 Skill。
- Agent 执行 Skill 时优先读取项目 OpenSpec 内 `agent/skills`。
- 如果项目 OpenSpec 内 Skill 缺失，才回退到 Kit 源目录。

这样可以同时满足：

```text
统一 Kit 入口
+
项目内 Skill 可复现
+
后续升级可控
```
