# Verification

## 目标

在 OpenSpec apply 完成后执行确定性验证，并生成统一 Verification 证据。

Verification 不等于"让 AI 看一遍代码"。

优先执行可以机器验证的检查。

## 输入

-   `.agent-env.md`
-   当前 OpenSpec change
-   当前需求和 Change Analysis
-   所有受影响 Git 仓库
-   项目已有构建、测试和静态检查能力

## 输出

在当前 OpenSpec change 目录生成或更新：

`verification.md`

## 执行步骤

### 1. 确认受影响仓库

根据：

-   Change Analysis
-   Design
-   Tasks
-   实际 Git diff

列出所有受影响仓库。

如果实际 diff 出现在 Design 未声明的仓库，记录异常。

### 2. 收集 Diff

对每个实现仓库检查：

-   `git status`
-   当前分支
-   `git diff`
-   `git diff --stat`

不得只 Review 当前打开的文件。

### 3. 发现项目原生验证方式

优先读取项目已有：

-   README
-   build 文件
-   CI 配置
-   Makefile / scripts
-   测试目录
-   静态检查配置

禁止在不了解项目构建方式时随意发明验证命令。

### 4. 执行确定性检查

根据项目实际能力执行：

-   编译
-   单元测试
-   集成测试
-   受影响模块测试
-   静态检查
-   格式检查
-   Schema / Mapper / 配置检查
-   自定义项目脚本

对无法执行的检查明确记录原因。

### 5. 验证关键业务场景

根据 specs、Change Analysis 中的不变量和 Design 风险，列出关键场景。

优先使用自动测试。

没有自动测试时，记录：

-   场景
-   输入条件
-   期望结果
-   当前验证方式
-   是否仍需人工验证

### 6. 输出 Verification Report

使用 `templates/verification.md`。

不得把"命令未执行"写成"验证通过"。

## 结论

只能使用：

-   `PASS`
-   `PASS WITH MANUAL CHECKS`
-   `FAIL`
-   `BLOCKED`

存在编译失败、关键测试失败或关键不变量验证失败时，结论必须是 `FAIL`。
