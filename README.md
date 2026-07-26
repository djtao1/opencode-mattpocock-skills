# Matt Pocock Agent Skills 中文版 — OpenCode 安装与使用指南

> 这是 [mattpocock/skills](https://github.com/mattpocock/skills) 的简体中文本地化版本，专为 [OpenCode](https://opencode.ai) 编码代理设计的技能集合。
>
> 原中文仓库: [vinvcn/mattpocock-skills-zh-CN](https://github.com/vinvcn/mattpocock-skills-zh-CN)

---

## 目录

- [一、概述](#一概述)
- [二、安装](#二安装)
- [三、快速开始](#三快速开始)
- [四、技能清单](#四技能清单)
- [五、使用示例](#五使用示例)
- [六、进阶技巧](#六进阶技巧)
- [七、FAQ](#七faq)
- [附录：目录结构](#附录目录结构)

---

## 一、概述

### 这是什么？

Matt Pocock Agent Skills 是一套**可复用的工程实践指令集**，解决 AI 编码代理常见的四大失败模式：

| # | 失败模式 | 对应技能 |
|---|---------|---------|
| 1 | Agent 没做你想要的东西 | `/grill-me`, `/grill-with-docs` |
| 2 | Agent 太啰嗦 | `/domain-modeling` (共享词汇) |
| 3 | 代码跑不起来 | `/tdd`, `/diagnosing-bugs` |
| 4 | 代码变成大泥球 | `/improve-codebase-architecture`, `/codebase-design` |

### 与 OpenCode 的关系

OpenCode 原生支持从 `~/.config/opencode/skills/<name>/SKILL.md` 加载技能。本仓库的 SKILL.md 格式与 OpenCode **完全兼容**（OpenCode 会忽略未知的 frontmatter 字段）。

安装后，技能会出现在 OpenCode 的 `<available_skills>` 提示中，代理可在适当时机按需加载。

---

## 二、安装

### 系统要求

- [OpenCode](https://opencode.ai) 已安装
- Windows (PowerShell 5.1+) 或 Linux/macOS
- Git

### 方式一：一键脚本安装（推荐）

在 PowerShell 中执行：

```powershell
# 从本仓库目录运行
.\install.ps1
```

或直接从 GitHub 安装：

```powershell
# 临时下载并运行
irm https://raw.githubusercontent.com/vinvcn/mattpocock-skills-zh-CN/main/install.ps1 | iex
```

### 方式二：手动安装

```powershell
# 1. 克隆仓库
git clone --depth 1 https://github.com/vinvcn/mattpocock-skills-zh-CN.git "$env:TEMP\matt-skills"

# 2. 进入目录并检出技能文件
Set-Location "$env:TEMP\matt-skills"
git sparse-checkout set skills

# 3. 复制到 OpenCode 全局技能目录
$dst = "$env:USERPROFILE\.config\opencode\skills"
$categories = @{
    "engineering"  = @("ask-matt","code-review","codebase-design","diagnosing-bugs","domain-modeling","grill-with-docs","implement","improve-codebase-architecture","prototype","research","resolving-merge-conflicts","setup-matt-pocock-skills","tdd","to-spec","to-tickets","triage","wayfinder")
    "productivity" = @("grill-me","grilling","handoff","teach","writing-great-skills")
    "misc"         = @("setup-pre-commit","scaffold-exercises")
}
foreach ($cat in $categories.Keys) {
    foreach ($name in $categories[$cat]) {
        $s = Join-Path "$env:TEMP\matt-skills\skills" $cat $name
        $d = Join-Path $dst $name
        if (Test-Path $s) { Copy-Item -Path $s -Destination $d -Recurse -Force }
    }
}

# 4. 清理
Remove-Item "$env:TEMP\matt-skills" -Recurse -Force
```

### 验证安装

```powershell
Get-ChildItem "$env:USERPROFILE\.config\opencode\skills" -Directory
```

应看到 24 个子目录。或者启动 opencode，在对话中查看 `<available_skills>` 列表是否包含这些技能。

---

## 三、快速开始

### 每个项目只需一次：运行 setup

首次在项目中使用前，需要在项目根目录运行：

```
/setup-matt-pocock-skills
```

该命令会：
1. 检测项目使用的版本控制系统（GitHub / GitLab / 本地）
2. 配置 issue tracker
3. 配置 triage labels
4. 配置领域文档（`CONTEXT.md` 和 ADR 目录）
5. 写入 `AGENTS.md` 或 `CLAUDE.md`

> 如果项目根没有 `AGENTS.md`，技能会询问你要创建哪一个。建议为 OpenCode 创建 `AGENTS.md`。

### 基本使用流程

```
你: /grill-me 我想实现用户管理功能
AI: [开始追问细节...]

你: /to-spec
AI: [把讨论整理成 spec]

你: /implement
AI: [基于 spec 实现，自动调用 /tdd 写测试]

你: /code-review
AI: [审查刚才的变更]
```

---

## 四、技能清单

### Engineering（工程类）

| 技能 | 触发词 | 描述 | 适用场景 |
|------|--------|------|---------|
| ask-matt | `/ask-matt` | 询问当前情境适合哪个技能或流程 | 不确定用什么技能时，先问它 |
| code-review | `/code-review` | 双轴审查：Standards vs Spec | 要提交前审查代码变更 |
| codebase-design | `/codebase-design` | 设计深模块的共享词汇和纪律 | 设计模块接口、找深化机会 |
| diagnosing-bugs | `/diagnosing-bugs` | 诊断循环：复现→最小化→假设→仪表→修复 | 棘手 bug、性能回退 |
| domain-modeling | `/domain-modeling` | 构建打磨领域模型 | 明确术语、记录架构决策 |
| grill-with-docs | `/grill-with-docs` | 追问式访谈 + 写文档(ADR/词汇表) | 复杂功能设计、需文档化 |
| implement | `/implement` | 基于 spec 或 ticket 集合实现 | 有了 spec 后开始编码 |
| improve-codebase-architecture | `/improve-codebase-architecture` | 扫描代码库，生成架构改进报告 | 代码变乱时重构 |
| prototype | `/prototype` | 构建一次性原型验证设计 | 探索 UI 或逻辑方案 |
| research | `/research` | 对照一手来源调研并保存 findings | 技术选型、方案调研 |
| resolving-merge-conflicts | `/resolving-merge-conflicts` | 逐个 hunk 解决 git 冲突 | merge/rebase 冲突 |
| setup-matt-pocock-skills | `/setup-matt-pocock-skills` | 配置项目 issue tracker 和 domain docs | **每个项目首次使用前必须跑一次** |
| tdd | `/tdd` | 测试驱动开发（红-绿-重构循环） | 写测试先行、需高质量代码 |
| to-spec | `/to-spec` | 把对话转为 spec 并发布 | 讨论完需求后输出文档 |
| to-tickets | `/to-tickets` | 把 spec 拆成 tracer-bullet tickets | 大功能拆解为可执行任务 |
| triage | `/triage` | 分类 issue/PR，写 agent-ready briefs | 管理 issue tracker |
| wayfinder | `/wayfinder` | 将大块工作规划成 decision tickets map | 跨 session 的大型项目规划 |

### Productivity（效率类）

| 技能 | 触发词 | 描述 | 适用场景 |
|------|--------|------|---------|
| grill-me | `/grill-me` | 追问式访谈，打磨计划或设计 | **最常用**：开始任何工作前先对齐 |
| grilling | `/grilling` | 追问循环（被其他技能调用） | 通常不直接调用 |
| handoff | `/handoff` | 把对话压缩成交接文档 | 需要另一个代理接手时 |
| teach | `/teach` | 在当前工作区中教学 | 学习新技能或概念 |
| writing-great-skills | `/writing-great-skills` | 编写和编辑优秀技能的参考 | 想自己写 skill 时查阅 |

### Misc（其他类）

| 技能 | 触发词 | 描述 | 适用场景 |
|------|--------|------|---------|
| setup-pre-commit | `/setup-pre-commit` | 配置 Husky pre-commit hooks | 项目需要提交前检查 |
| scaffold-exercises | `/scaffold-exercises` | 创建练习目录结构 | 制作教程或培训材料 |

---

## 五、使用示例

### 示例 1：实现一个新功能（完整流程）

```
你: /grill-with-docs 我想给 license-server 加自动备份数据库的功能
AI: [追问细节：备份频率？保留数量？压缩？存储位置？]
    同时创建 ADR 记录关键决策

你: /to-spec
AI: [生成 spec 文档]

你: /implement
AI: [调用 /tdd 先写测试，再实现功能]
```

### 示例 2：快速追问

```
你: /grill-me 帮我规划一下这个项目的 API 设计
AI: [快速追问，不做文档化]
```

### 示例 3：代码审查

```
你: 帮我看看我刚改的这段代码
AI: [自动识别为 code-review 场景]

--- 或显式调用 ---

你: /code-review
```

### 示例 4：诊断问题

```
你: /diagnosing-bugs 页面加载后白屏，没有报错
AI: 步骤1: 复现问题
    步骤2: 最小化复现条件
    步骤3: 提出假设
    步骤4: 添加仪表输出
    步骤5: 修复
    步骤6: 加回归测试
```

### 示例 5：研究调研

```
你: /research 调研 SQLite 备份的最佳实践
AI: [查阅 SQLite 官方文档、常见方案对比]
    [把 findings 保存为 docs/research/sqlite-backup.md]
```

---

## 六、进阶技巧

### 1. 技能权限配置

在 `~/.config/opencode/opencode.json` 或项目根 `opencode.json` 中配置：

```json
{
  "permission": {
    "skill": {
      "grill-with-docs": "allow",
      "code-review": "allow",
      "tdd": "allow",
      "personal-*": "deny",
      "*": "ask"
    }
  }
}
```

| 权限 | 行为 |
|------|------|
| `allow` | 技能立即可用 |
| `deny` | 技能隐藏，拒绝访问 |
| `ask` | 加载前询问用户 |

### 2. 更新技能

重新运行安装脚本即可覆盖更新：

```powershell
.\install.ps1
```

### 3. 编写自定义技能

参考 `/writing-great-skills` 技能，在 `~/.config/opencode/skills/<name>/SKILL.md` 中创建自己的技能。

### 4. 项目级覆盖

将技能放在项目 `.opencode/skills/<name>/` 中可覆盖全局同名技能。

---

## 七、FAQ

### Q: 技能安装后看不到？

检查：
1. `SKILL.md` 文件名必须是全大写
2. 确保 `name` 和 `description` 在 frontmatter 中
3. 检查 `opencode.json` 中权限是否为 `allow`
4. 重启 opencode 会话

### Q: 技能名称必须是小写加连字符吗？

是的。OpenCode 要求名称匹配 `^[a-z0-9]+(-[a-z0-9]+)*$`。本仓库所有技能名称已符合此规范。

### Q: 可以不全局安装，只在某个项目用吗？

可以。将技能复制到项目根下的 `.opencode/skills/<name>/` 即可。

### Q: 如何备份已安装的技能？

```powershell
Copy-Item "$env:USERPROFILE\.config\opencode\skills" "$env:USERPROFILE\.config\opencode\skills-backup" -Recurse
```

### Q: 斜杠命令在 OpenCode 中如何工作？

OpenCode 没有内置的 `/command` 机制。技能通过 `skill` 工具按需加载，代理根据对话内容判断使用哪个技能。但你**可以在对话中以 `/skill-name` 开头**，代理会识别并主动加载对应技能。

---

## 附录：目录结构

安装后的技能目录结构：

```
%USERPROFILE%\.config\opencode\skills\
├── ask-matt\SKILL.md                        # skill 路由器
├── codebase-design\SKILL.md                 # 深模块设计
├── code-review\SKILL.md                     # 代码审查
├── diagnosing-bugs\SKILL.md                 # 诊断循环
├── domain-modeling\SKILL.md                 # 领域建模
├── grill-me\SKILL.md                        # 快速追问
├── grill-with-docs\SKILL.md                 # 追问+文档
├── grill-with-docs\AGENT-BRIEF.md           # 辅助文件
├── grilling\SKILL.md                        # 追问循环
├── handoff\SKILL.md                         # 交接文档
├── implement\SKILL.md                       # 实现
├── improve-codebase-architecture\SKILL.md   # 架构改进
├── prototype\SKILL.md                       # 原型
├── research\SKILL.md                        # 调研
├── resolving-merge-conflicts\SKILL.md       # 冲突解决
├── scaffold-exercises\SKILL.md              # 练习脚手架
├── setup-matt-pocock-skills\SKILL.md        # ★ 配置
├── setup-matt-pocock-skills\issue-tracker-*.md  # 模板文件
├── setup-pre-commit\SKILL.md                # pre-commit
├── tdd\SKILL.md                             # TDD
├── teach\SKILL.md                           # 教学
├── to-spec\SKILL.md                         # 写 spec
├── to-tickets\SKILL.md                      # 拆 tickets
├── triage\SKILL.md                          # 分类管理
├── wayfinder\SKILL.md                       # 大规划
└── writing-great-skills\SKILL.md            # skill 编写参考
```

本仓库目录结构：

```
opencode_development/
├── README.md            # 本文档
├── install.ps1          # 一键安装脚本
└── skills/              # 技能清单说明目录
```

---

> 文档维护时间: 2026-07-26
> 技能来源: [vinvcn/mattpocock-skills-zh-CN](https://github.com/vinvcn/mattpocock-skills-zh-CN)
> 当前技能数: 24 个
