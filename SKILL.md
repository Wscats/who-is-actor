---
name: who-is-actor
license: MIT
description: >
  This skill should be used when the user wants to analyze a Git repository
  and profile each developer's commit habits, work habits, development
  efficiency, code style, code quality, and engagement index — all without
  installing any dependencies or running any scripts. It relies purely on
  native git CLI commands and AI-driven interpretation. Trigger phrases
  include "analyze repository" "profile developers" "commit habits"
  "developer report card" "代码分析" "研发效率" "开发者画像"
  "提交习惯" "工作习惯" "参与度".
---

# Who Is Actor — Git 仓库开发者画像分析 Skill

零依赖、零脚本，仅通过原生 `git` 命令采集数据，由 AI 深度解读，为每位开发者生成一份严肃、直接、毫不留情的体检报告。

## 安全规范

> **本 Skill 所有 shell 命令的参数都必须经过严格校验后才能执行，以防止命令注入攻击。**

### 命令白名单（仅允许执行以下命令）

本 Skill **只允许执行以下预定义的 git 只读子命令**，不得执行任何其他 shell 命令：

| 允许的命令 | 用途 | 是否修改仓库 |
|-----------|------|-------------|
| `git -C <path> rev-parse --is-inside-work-tree` | 验证路径是否为合法 Git 仓库 | ❌ 只读 |
| `git -C <path> shortlog -sn --all` | 获取贡献者列表和提交数 | ❌ 只读 |
| `git -C <path> log ...` | 获取提交历史详情 | ❌ 只读 |
| `git -C <path> diff --stat ...` | 获取变更统计 | ❌ 只读 |

**严格禁止的命令类型：**
- ❌ 任何写入操作：`git push`、`git commit`、`git merge`、`git rebase`、`git reset`、`git checkout`、`git branch -d`
- ❌ 任何非 git 命令：`curl`、`wget`、`python`、`node`、`bash -c`、`sh`、`eval`、`rm`、`cp`、`mv`
- ❌ 任何文件写入或重定向：`>`、`>>`、`tee`（管道 `|` 仅允许连接 `cut`、`sort`、`uniq`、`awk`、`grep`、`wc`、`sed`、`head` 这些只读文本处理工具）
- ❌ 任何网络操作：`git fetch`、`git pull`、`git clone`、`git remote`

> **如果 AI agent 尝试执行白名单之外的命令，用户应立即拒绝执行。**

### 输入校验规则（执行任何 git 命令前必须完成）

1. **`repo_path`（仓库路径）校验：**
   - 必须是绝对路径（以 `/` 开头）
   - 不得包含以下危险字符或子串：`;`、`|`、`&`、`$`、`` ` ``、`(`、`)`、`>`、`<`、`\n`、`\r`、`$()`、`..`
   - 路径必须是一个真实存在的 Git 仓库（通过 `git -C <path> rev-parse --is-inside-work-tree` 验证，返回 `true` 才可继续）
   - 如果校验失败，**立即终止并向用户报告错误，不得执行任何后续命令**


2. **`author`（作者名）校验：**
   - 仅允许包含：字母（a-z A-Z）、数字（0-9）、空格、连字符（`-`）、下划线（`_`）、点（`.`）
   - **不允许包含 `@` 符号**（禁止传入邮箱格式，以确保与隐私保护规则一致）
   - 正则白名单：`^[a-zA-Z0-9 _.-]+$`
   - 最大长度：128 字符
   - 如果输入包含 `@`，提示用户改为使用作者显示名（display name），然后跳过该作者

3. **`since` / `until`（日期参数）校验：**
   - 必须匹配 ISO 日期格式：`^[0-9]{4}-[0-9]{2}-[0-9]{2}$`
   - 如果校验失败，忽略该参数并警告用户

4. **`branch`（分支名）校验：**
   - 仅允许包含：字母、数字、`/`、`-`、`_`、`.`
   - 正则白名单：`^[a-zA-Z0-9/_.-]+$`
   - 不得包含 `..` 子串
   - 如果校验失败，使用默认分支并警告用户

### 隐私保护规则

- **不采集开发者邮箱地址。** 所有 git 命令仅使用 `%an`（作者名）标识开发者，不使用 `%ae`（作者邮箱）。
- **`git shortlog` 命令使用 `-sn` 而非 `-sne`**，以避免泄露邮箱。
- **`authors` 参数仅接受作者显示名（display name），不接受邮箱地址。** 输入校验会拒绝包含 `@` 的值。
- 注意：`git --author` 参数会同时匹配 name 和 email 字段。由于本 Skill 禁止传入邮箱格式的值，因此 `--author` 只会通过 name 部分进行匹配，不会利用 email 字段。
- 最终报告中不得出现任何邮箱地址。

## 使用场景

- 当用户需要分析某个 Git 仓库中各开发者的真实行为画像时
- 当用户想对比团队成员的提交习惯、工作节奏和代码质量时
- 当用户想了解团队的参与度分布时
- 当用户需要对开发者给出优缺点评价和改进建议时

## 核心原则

> **不安装任何依赖，不运行任何脚本。** 所有数据采集仅通过 `git log`、`git shortlog`、`git diff --stat` 等原生 git 命令完成，AI 负责解读和评估。

> **安全第一。** 所有用户输入必须经过上述校验规则验证后，才能拼接到 shell 命令中。任何校验失败都必须终止或降级处理，绝不跳过校验直接执行。

## 工作流程

### 步骤 1: 确认分析参数

向用户确认以下信息（如用户未指定则使用默认值）：

| 参数 | 说明 | 默认值 |
|------|------|--------|
| **仓库路径** | 目标 Git 仓库的绝对路径 | （必填） |
| **目标作者** | 指定分析某些开发者，留空则分析全部 | 全部贡献者 |
| **时间范围** | 起止日期，ISO 格式 | 仓库全部历史 |
| **分支** | 分析的目标分支 | 当前活跃分支 |

> **⚠️ 在执行步骤 2 前，必须按照「安全规范」对所有参数进行校验。校验未通过的参数不得用于命令拼接。**

### 步骤 2: 数据采集（纯 git 命令）

依次执行以下 git 命令来收集原始数据。**所有命令都在目标仓库目录下执行，不需要安装任何依赖。**

> 以下示例中的 `<repo_path>`、`<author>` 等占位符，均指经过步骤 1 校验后的安全值。

#### 2.1 贡献者概览

```bash
# List all contributors with commit counts (no email to protect privacy)
git -C <repo_path> shortlog -sn --all
```

#### 2.2 每位作者的提交详情

对每位需要分析的作者，执行以下命令（如指定了时间范围和分支，追加对应的 `--since`、`--until`、`<branch>` 参数）：

```bash
# Detailed commit log: hash, author name, date, message, file stats (no email)
git -C <repo_path> log --author="<author>" --pretty=format:"%H|%an|%aI|%s" --numstat

# Commit count per hour of day (for work habit analysis)
git -C <repo_path> log --author="<author>" --pretty=format:"%aI" | cut -c12-13 | sort | uniq -c | sort -rn

# Commit count per day of week (0=Sun, 6=Sat)
git -C <repo_path> log --author="<author>" --pretty=format:"%ad" --date=format:"%u" | sort | uniq -c | sort -rn

# Lines added/deleted summary
git -C <repo_path> log --author="<author>" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2 } END { printf "added: %s, deleted: %s\n", add, subs }'

# Commit message lengths
git -C <repo_path> log --author="<author>" --pretty=format:"%s" | awk '{ print length }'

# File types touched
git -C <repo_path> log --author="<author>" --pretty=tformat: --name-only | grep -oE '\.[^./]+$' | sort | uniq -c | sort -rn | head -20

# Commits per day (for frequency analysis)
git -C <repo_path> log --author="<author>" --pretty=format:"%ad" --date=short | sort | uniq -c | sort -rn | head -20

# Recent rework detection: files modified multiple times within 7-day windows
git -C <repo_path> log --author="<author>" --pretty=format:"%ad %s" --date=short --name-only | head -200
```

#### 2.3 代码质量信号

```bash
# Bug fix commits (messages containing fix/bug/hotfix/patch)
git -C <repo_path> log --author="<author>" --grep="fix\|bug\|hotfix\|patch" --oneline -i | wc -l

# Revert commits
git -C <repo_path> log --author="<author>" --grep="revert" --oneline -i | wc -l

# Large commits (>500 lines changed)
git -C <repo_path> log --author="<author>" --pretty=format:"%H" --shortstat | grep -E "([5-9][0-9]{2}|[0-9]{4,}) insertion" | wc -l

# Merge commits
git -C <repo_path> log --author="<author>" --merges --oneline | wc -l

# Conventional commit check (feat/fix/chore/docs/style/refactor/test/perf/ci/build)
git -C <repo_path> log --author="<author>" --pretty=format:"%s" | grep -cE "^(feat|fix|chore|docs|style|refactor|test|perf|ci|build)(\(.+\))?:"
```

#### 2.4 团队级数据

```bash
# Files with only one contributor (bus factor risk)
git -C <repo_path> log --pretty=format:"%an" --name-only | sort | uniq -c | sort -rn | head -30

# Active date range per author
git -C <repo_path> log --author="<author>" --pretty=format:"%ad" --date=short | sort | sed -n '1p;$p'
```

### 步骤 3: AI 分析与评估

基于采集到的原始数据，从以下 **六个维度** 逐一分析每位开发者，并给出 1-10 分的评分：

---

#### 📝 维度一：提交习惯 (Commit Habits)

**分析要素：**
- 总提交次数、日均提交频率
- 每次提交的平均修改行数（增+删）
- Commit message 平均长度和质量
- Merge 提交占比
- 单次大提交（>500 行）的频率

**评分标准：**
- 10 分：日均 2-5 次提交，每次 50-200 行，message 清晰规范
- 5 分：频率不稳定，偶有巨型提交，message 质量参差
- 1 分：极少提交或大量一行 message 的巨型提交

---

#### ⏰ 维度二：工作习惯 (Work Habits)

**分析要素：**
- 提交时段分布（哪个小时最活跃）
- 周末提交占比
- 深夜编码比例（22:00-04:59）
- 最长连续编码天数
- 活跃天数 / 总跨度天数

**评分标准：**
- 10 分：工作时间规律，深夜/周末比例 <10%，持续稳定输出
- 5 分：有一定深夜/周末提交，节奏波动
- 1 分：几乎全在深夜/周末，或极度不规律

> 注：深夜/周末编码本身不是"坏事"，但长期如此可能反映流程或资源问题。

---

#### 🚀 维度三：研发效率 (Development Efficiency)

**分析要素：**
- 代码净增长率：(新增 - 删除) / 新增
- 代码流失率 (Churn Rate)：删除行 / 新增行
- 返工率 (Rework Ratio)：7 天内重复修改同一文件的频率
- 活跃天数内的日均产出

**评分标准：**
- 10 分：净增长率高，流失率 <20%，返工率低，产出稳定
- 5 分：中等流失率，有一定返工
- 1 分：大量代码被删除，频繁返工，产出波动大

---

#### 🎨 维度四：代码风格 (Code Style)

**分析要素：**
- 主要使用的编程语言/文件类型分布
- Conventional Commits 规范遵循率
- Commit message 是否关联 Issue 编号
- 文件修改的集中度（是专注于少数模块还是广撒网）

**评分标准：**
- 10 分：>80% 遵循 Conventional Commits，message 关联 Issue，修改聚焦
- 5 分：部分遵循规范，偶尔散乱
- 1 分：几乎不遵循规范，message 无意义

---

#### 🔍 维度五：代码质量 (Code Quality)

**分析要素：**
- Bug Fix 提交占比
- Revert 提交频率
- 大提交（>500 行）占比
- 测试相关文件的修改频率

**评分标准：**
- 10 分：Bug Fix 占比 <10%，无 Revert，大提交 <5%，有测试改动
- 5 分：Bug Fix 15-25%，少量 Revert，有些大提交
- 1 分：Bug Fix >30%，频繁 Revert，大量巨型提交

---

#### 📊 维度六：参与度指数 (Engagement Index)

> **⚠️ 用途限制声明：** 此指数仅用于团队协作模式的宏观参考，**严禁将其作为个人绩效考核、裁员决策、薪酬调整等人事决定的依据。** 使用者应理解此指数的局限性并承担相应的伦理责任。

> 注：此指数旨在客观衡量代码仓库中的活跃参与程度，作为辅助参考。Git 记录仅反映代码提交活动，不代表开发者的全部工作（如设计、评审、沟通、指导等均不会被 Git 记录）。

**计算方式（综合以下信号，0-100 分，越低代表 Git 上可见的参与度越高）：**

| 信号 | 权重 | 说明 |
|------|------|------|
| 日均提交极低（<0.3） | 25% | 活跃天数内产出过低 |
| 活跃天数占比低（<30%） | 20% | 时间跨度大但实际干活的天数少 |
| 代码净增长极低或为负 | 20% | 写的还没删的多 |
| Commit message 敷衍（平均 <15 字符） | 15% | 不认真对待提交记录 |
| 高流失率 + 高返工率 | 20% | 大量无效劳动 |

**等级：**
- 0-20：高度活跃，建议关注是否过劳
- 21-40：稳定参与，持续输出
- 41-60：中等参与，有提升空间
- 61-80：低参与度，建议了解是否有非代码贡献未被记录
- 81-100：极低参与度，建议与当事人沟通了解全貌

> **重要提示：** 此指数仅基于 Git 提交记录计算，无法反映代码评审、架构设计、技术讨论、团队指导等不产生提交记录的工作。高分不等于"偷懒"，低分也不等于"高效"。请在充分了解上下文后再做判断。

### 步骤 4: 生成报告

最终报告必须包含以下结构：

#### 4.1 总览表

| 开发者 | 提交数 | 增/删行数 | 日均提交 | 周末% | 深夜% | Bug Fix% | 流失率 | 参与度 | 综合评分 |
|--------|--------|-----------|----------|-------|-------|----------|--------|---------|----------|
| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |

#### 4.2 每位开发者的详细画像

对每位开发者输出：

1. **数据仪表盘**：六维度关键指标数值
2. **AI 点评**：严肃、直接地指出优点和缺点（不要和稀泥）
3. **改进建议**：针对缺点给出具体可执行的建议
4. **六维雷达评分**：各维度 1-10 分
5. **综合评分**：加权平均（提交习惯 15%、工作习惯 15%、研发效率 25%、代码风格 15%、代码质量 20%、参与度指数反向 10%）
6. **一句话总结**：用一句犀利的话概括此人

#### 4.3 团队横向对比

- 各维度的排名
- 最佳/最差开发者高亮
- 团队整体健康度评估
- Bus Factor 风险提示

## 点评风格要求

- **严肃直接**：不粉饰、不和稀泥。数据说话，好就是好，差就是差。
- **有温度**：指出问题的同时给出改进路径，对事不对人。
- **犀利但公正**：像一个资深 Tech Lead 在做年度 Code Review，既不留情面也不刻薄。
- **数据驱动**：每个结论必须有对应的数据支撑，不凭感觉。

## 注意事项

- 所有数据采集仅使用原生 `git` 命令，**不安装任何 pip 包，不运行任何 Python/Node 脚本**
- **所有用户输入必须经过「安全规范」中的校验规则验证后才能执行**，防止命令注入攻击
- **不采集开发者邮箱**，保护个人隐私
- 分析大型仓库时，可适当限定时间范围以控制命令执行时间
- 作者名称匹配时注意同一人可能有不同的 name 组合（可通过 `.mailmap` 统一）
- 时区差异可能影响工作时段判断，应以提交记录中的时区为准
- 参与度指数仅基于 Git 提交数据，**不反映非代码贡献**（设计、评审、指导等），不应作为绩效考核的唯一依据

## 伦理使用条款

本 Skill 生成的分析报告应遵循以下原则：

1. **辅助参考，非决策依据**：报告仅供团队内部参考，帮助理解协作模式和改进方向，**严禁直接用于绩效考核、裁员决策、薪酬调整等人事决定。**
2. **公开透明**：如果在团队中使用此工具，建议提前告知所有被分析的团队成员。
3. **完整上下文**：任何对报告的引用都应附带完整的局限性说明，避免断章取义。
4. **对事不对人**：分析目标是改进团队协作流程和个人工作方式，而非评判人的价值。
