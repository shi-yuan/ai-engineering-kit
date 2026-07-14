# 项目接入指南

## 1. 在 OpenSpec 仓库增加项目规则

创建：

``` text
<project>-openspec/
└── agent/
    └── project-rules.md
```

可以从：

`project-template/agent/project-rules.md`

复制后按项目实际情况修改。

## 2. 检查 project-context

至少维护：

``` text
openspec/project-context/
├── system-overview.md
├── architecture.md
├── module-map.md
├── data-model.md
└── business/
```

`module-map.md` 必须明确 Git 仓库相对位置和跨仓关系。

## 3. 合并 OpenSpec 配置

参考：

`project-template/openspec-config-fragment.yaml`

将规则合并到现有 `openspec/config.yaml`。

不要直接覆盖已有项目配置。

## 4. 执行 setup

以 `xyy-order` 为例：

``` powershell
./scripts/setup-agent.ps1 `
  -ProjectRoot ../xyy-order `
  -OpenSpecRepo ../xyy-order/xyy-order-openspec
```

## 5. 从聚合目录启动 Agent

``` text
xyy-order/
```

不要从：

``` text
xyy-order-core/
xyy-order-business/
xyy-order-openspec/
```

单独启动历史改造任务。

## 6. 首次验证

选择一个已经完成、人工知道正确答案的历史需求进行回放。

统计：

1.  业务语义误判数
2.  影响范围遗漏数
3.  Design 重大偏差数
4.  代码重大返工数

不要仅以"代码能编译"评价接入效果。
