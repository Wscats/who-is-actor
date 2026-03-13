---
name: who-is-actor
license: MIT
description: >
  This skill should be used when the user wants to analyze a Git repository
  and profile each developer's commit habits, work habits, development
  efficiency, code style, code quality, and slacking index — all without
  installing any dependencies or running any scripts. It relies purely on
  native git CLI commands and AI-driven interpretation. Trigger phrases
  include "analyze repository" "profile developers" "who is slacking"
  "commit habits" "developer report card" "代码分析" "摸鱼指数"
  "研发效率" "开发者画像" "提交习惯" "工作习惯".
---

# Who Is Actor — Git 仓库开发者画像分析 Skill

零依赖、零脚本，仅通过原生 `git` 命令采集数据，由 AI 深度解读，为每位开发者生成一份严肃、直接、毫不留情的体检报告。

## 使用场景

- 当用户需要分析某个 Git 仓库中各开发者的真实行为画像时
- 当用户想对比团队成员的提交习惯、工作节奏和代码质量时
- 当用户好奇"谁在摸鱼"时
- 当用户需要对开发者给出优缺点评价和改进建议时

## 核心原则

> **不安装任何依赖，不运行任何脚本。** 所有数据采集仅通过 `git log`、`git shortlog`、`git diff --stat` 等原生 git 命令完成，AI 负责解读和评估。

## 工作流程

### 步骤 1: 确认分析参数

向用户确认以下信息（如用户未指定则使用默认值）：

| 参数 | 说明 | 默认值 |
|------|------|--------|
| **仓库路径** | 目标 Git 仓库的绝对路径 | （必填） |
| **目标作者** | 指定分析某些开发者，留空则分析全部 | 全部贡献者 |
| **时间范围** | 起止日期，ISO 格式 | 仓库全部历史 |
| **分支** | 分析的目标分支 | 当前活跃分支 |

### 步骤 2: 数据采集（纯 git 命令）

依次执行以下 git 命令来收集原始数据。**所有命令都在目标仓库目录下执行，不需要安装任何依赖。**

#### 2.1 贡献者概览

```bash
# List all contributors with commit counts
git -C <repo_path> shortlog -sne --all
```

#### 2.2 每位作者的提交详情

对每位需要分析的作者，执行以下命令（如指定了时间范围和分支，追加对应的 `--since`、`--until`、`<branch>` 参数）：

```bash
# Detailed commit log: hash, author, date, message, file stats
git -C <repo_path> log --author="<author>" --pretty=format:"%H|%an|%ae|%aI|%s" --numstat

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

#### 🐟 维度六：摸鱼指数 (Slacking Index)

**计算方式（综合以下信号，0-100 分，越高越"摸鱼"）：**

| 信号 | 权重 | 说明 |
|------|------|------|
| 日均提交极低（<0.3） | 25% | 活跃天数内产出过低 |
| 活跃天数占比低（<30%） | 20% | 时间跨度大但实际干活的天数少 |
| 代码净增长极低或为负 | 20% | 写的还没删的多 |
| Commit message 敷衍（平均 <15 字符） | 15% | 不认真对待提交记录 |
| 高流失率 + 高返工率 | 20% | 大量无效劳动 |

**等级：**
- 0-20：劳模，建议关注是否过劳
- 21-40：踏实，稳定输出
- 41-60：中等，有提升空间
- 61-80：需关注，可能存在效率或动力问题
- 81-100：重度摸鱼，建议深入了解原因

### 步骤 4: 生成报告

最终报告必须包含以下结构：

#### 4.1 总览表

| 开发者 | 提交数 | 增/删行数 | 日均提交 | 周末% | 深夜% | Bug Fix% | 流失率 | 摸鱼指数 | 综合评分 |
|--------|--------|-----------|----------|-------|-------|----------|--------|---------|----------|
| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |

#### 4.2 每位开发者的详细画像

对每位开发者输出：

1. **数据仪表盘**：六维度关键指标数值
2. **AI 点评**：严肃、直接地指出优点和缺点（不要和稀泥）
3. **改进建议**：针对缺点给出具体可执行的建议
4. **六维雷达评分**：各维度 1-10 分
5. **综合评分**：加权平均（提交习惯 15%、工作习惯 15%、研发效率 25%、代码风格 15%、代码质量 20%、摸鱼指数反向 10%）
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
- 分析大型仓库时，可适当限定时间范围以控制命令执行时间
- 作者名称匹配时注意同一人可能有不同的 name/email 组合
- 时区差异可能影响工作时段判断，应以提交记录中的时区为准
- 摸鱼指数仅供参考和娱乐，不应作为绩效考核的唯一依据
