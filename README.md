# AI Engineering Kit V1.1

面向长期生产使用的共享 Agent Engineering Kit。

适用场景：

-   大型历史项目
-   多 Git 仓库
-   OpenSpec
-   Claude Code / Codex / CodeBuddy 等 Agent 混合使用
-   历史功能改造明显多于纯新功能开发

## 一、核心设计

V1.1 不再要求每个项目复制一整套 `agent/`。

统一维护一个独立 Git 仓库：

``` text
ai-engineering-kit/
├── AGENTS.base.md
├── adapters/
├── skills/
└── scripts/
```

每个项目自己的 OpenSpec 仓库只维护项目差异：

``` text
xyy-order-openspec/
├── agent/
│   └── project-rules.md
└── openspec/
    ├── project-context/
    ├── requirements/
    ├── changes/
    ├── specs/
    └── config.yaml
```

最终由 `setup-agent` 生成聚合工作区：

``` text
xyy-order/
├── AGENTS.md
├── CLAUDE.md
├── CODEBUDDY.md
├── .agent-env.md
├── .agents/
│   └── skills/
├── xyy-order-openspec/
├── xyy-order-core/
└── xyy-order-business/
```

## 二、职责边界

### ai-engineering-kit

维护团队通用工程方法：

-   Brownfield Analysis
-   Design Review
-   Verification
-   Change Review
-   Agent Adapter
-   setup 脚本

禁止写具体项目业务知识。

### project-rules.md

维护项目级 Agent 规则，例如：

-   Java 版本
-   技术栈
-   金额处理约束
-   RPC / MQ / SQL 特殊检查要求
-   项目特有工程限制

### project-context

维护长期项目知识：

-   系统概览
-   架构
-   模块和仓库关系
-   数据模型
-   业务流程
-   业务不变量

### OpenSpec Change

维护单次需求的 Proposal、Specs、Design、Tasks 等 Artifact。

## 三、推荐目录

``` text
workspace/
├── ai-engineering-kit/             # 独立 Git Repo
│
├── xyy-order/
│   ├── xyy-order-openspec/         # Git Repo
│   ├── xyy-order-core/             # Git Repo
│   └── xyy-order-business/         # Git Repo
│
└── xyy-pop/
    ├── xyy-pop-openspec/
    ├── xyy-pop-core/
    └── xyy-pop-business/
```

`ai-engineering-kit` 不要求位于项目目录内部。

## 四、安装

Windows：

``` powershell
cd ai-engineering-kit

./scripts/setup-agent.ps1 `
  -ProjectRoot ../xyy-order `
  -OpenSpecRepo ../xyy-order/xyy-order-openspec
```

Linux/macOS：

``` bash
cd ai-engineering-kit

bash ./scripts/setup-agent.sh \
  ../xyy-order \
  ../xyy-order/xyy-order-openspec
```

setup 会：

1.  合并 `AGENTS.base.md` 与项目 `project-rules.md`
2.  生成项目聚合目录 `AGENTS.md`
3.  同步公共 Skills 到 `.agents/skills`
4.  安装 Claude Code / CodeBuddy Adapter
5.  生成 `.agent-env.md`
6.  记录 Kit 版本和 OpenSpec Root

## 五、升级

更新共享 Kit：

``` bash
git pull
```

重新执行 setup 即可。

项目自己的：

-   `project-rules.md`
-   `project-context`
-   OpenSpec Artifact

不会被共享 Kit 覆盖。

## 六、默认工作流

``` text
需求
  ↓
brownfield-analysis
  ↓
20-change-analysis.md
  ↓
OpenSpec propose
  ↓
design-review
  ↓
人工 Review
  ↓
OpenSpec apply
  ↓
verification
  ↓
change-review
  ↓
OpenSpec archive
```

## 七、版本原则

共享 Kit 必须独立版本管理。

建议使用 Git Tag：

``` text
v1.1.0
v1.2.0
v2.0.0
```

生产项目升级 Kit 后，应至少回放一个已知历史需求，确认 Skill
行为没有明显退化。
