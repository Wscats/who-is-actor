---
name: who-is-actor
license: MIT
description: >
  This skill should be used ONLY when the user EXPLICITLY and UNAMBIGUOUSLY
  requests a Git repository commit-history analysis that produces aggregate
  collaboration-pattern metrics (commit cadence, churn, rework signals,
  conventional-commit compliance, bus-factor risk).

  The skill is scoped to repository-level technical analysis. It is NOT a
  performance-management, HR, ranking, or personnel-evaluation tool, and
  agents MUST refuse to use its output for those purposes. Any developer
  display names appearing in output exist solely to attribute Git commit
  records, not to render judgments about individuals.

  Activation requires an explicit, opt-in user request that BOTH (a)
  states a clear analyze-this-Git-repository intent AND (b) supplies a
  concrete repository path (or unambiguous repo reference). Generic
  conversational mentions of "analyze repository", "profile developers",
  "commit habits", "developer report card", "code quality", "team
  efficiency", "work habits", "engagement", "代码分析", "研发效率",
  "开发者画像", "提交习惯", "工作习惯", or "参与度" WITHOUT a
  repository path or explicit "analyze this Git repository" framing
  are NOT sufficient to activate this skill. In that situation the agent
  MUST first (1) confirm the user actually wants to run repository
  profiling, (2) request a concrete repository path, (3) confirm the
  user has authority to analyze that repository, (4) remind the user
  that other contributors' Git metadata will be processed, and (5)
  recommend Dry-Run preview — only after these are resolved may any
  git command be executed.

  Activation phrases (must include an explicit analyze-this-repo intent
  AND a repository path or unambiguous repo reference): "analyze the git
  repository at <path>", "run who-is-actor on <path>", "profile developers
  in this repo at <path>", "generate a developer report card for the repo
  at <path>", "分析仓库 <path>", "对 <path> 这个 git 仓库做开发者画像".

  Privacy & data-handling: relies purely on native git read-only CLI
  commands and standard Unix text-processing utilities. Developer emails
  are never collected. Commit message text and full file paths are
  processed strictly locally and reduced to numeric aggregates BEFORE
  any data leaves the local environment; only aggregated metrics
  (counts, averages, ratios, extension-level statistics) are forwarded
  to the AI model. The collection commands themselves emit raw subjects
  and paths — these MUST be treated as local-only intermediate values
  and never placed into AI prompts, tool arguments, or other off-host
  contexts. See "Sensitive Data Filtering Rules" for mandatory
  enforcement details.
---

# Who Is Actor — Git Repository Developer Profiling Skill

> 🔗 **Project Repository:** [https://github.com/wscats/who-is-actor](https://github.com/wscats/who-is-actor)

Zero *install* dependencies, zero scripts. Collects data purely through native read-only `git` commands and standard Unix text utilities (`cut`, `sort`, `awk`, `grep`, etc. — already present on most systems). The AI is responsible only for interpreting **already-aggregated, locally-redacted statistical metrics** to generate a collaboration-pattern report.

> ⚠️ **READ THIS BEFORE USING — Privacy, Consent & Scope Notice**
>
> 1. **Other people's data may be involved.** A Git repository typically contains commit metadata (display names, timestamps, commit message subjects, file paths) authored by people other than the user invoking this skill. Before running, the user MUST confirm they have authority to analyze the repository and that doing so does not violate workplace, contractual, or local-law obligations. The agent SHOULD remind the user to inform analyzed contributors when used in a team context.
> 2. **Not for HR / personnel decisions.** The output, including the engagement index and any individual scoring, MUST NOT be used as the basis for performance reviews, hiring/firing decisions, compensation, layoffs, ranking, or any personnel-style judgment of individuals. The agent MUST refuse such requests and respond only with non-personalized, aggregate observations.
> 3. **Sensitive content may exist in commit metadata.** Commit messages and filenames can contain ticket IDs, incident references, secrets, customer names, URLs, or other confidential information. This skill mandates that such raw text remain **local-only** and that only aggregate, redacted metrics ever reach the AI model. See "Sensitive Data Filtering Rules" for binding enforcement.
> 4. **Read-only, scoped, no network.** The skill executes only the read-only git subcommands enumerated in the Command Whitelist, against the single user-supplied repository path. No writes, no network, no traversal outside the repo root.

> **"Zero dependency" clarification:** This skill installs nothing — no pip packages, no npm modules, no custom scripts. However, it **does require** the following standard system binaries to be available on the host: `git`, `cut`, `sort`, `uniq`, `awk`, `grep`, `sed`, `wc`, `head`. These are pre-installed on virtually all Unix-like systems (macOS, Linux). On Windows, use Git Bash or WSL.

---

## 💬 Natural Language Examples (For Reference Only — A Repository Path Is ALWAYS Required)

> ⚠️ **Hard activation constraint (binding on the agent):** The phrasings below are reference templates for expressing intent. The agent **MUST NOT** start collection merely because the user mentioned topics like "analyze repository", "profile developers", "commit habits", "developer report card", "code quality", "engagement", "研发效率", or "开发者画像". Collection may begin **only** after ALL of the following are satisfied:
>
> 1. The user has explicitly stated an intent to analyze a specific Git repository;
> 2. The user has supplied a concrete repository path (absolute) or an unambiguous repo reference;
> 3. The user has confirmed they have authority to analyze that repository, and (in team contexts) has informed or will inform the analyzed contributors;
> 4. The user has acknowledged the privacy notice and that the report MUST NOT be used for personnel decisions;
> 5. Dry-Run preview is recommended before actual execution.
>
> If the user uses any of the phrasings below **without supplying a repository path**, the agent MUST first ask for the repository path and authority confirmation, and only then proceed.

You don't need to memorize any commands or parameters — simply describe what you need in any language (please supply an absolute repository path along with the request):

### English

```
💬 "Analyze the repository at /path/to/my-project"
💬 "Profile all developers in this repo"
💬 "Who are the most active contributors in /path/to/my-project?"
💬 "Compare commit habits of Alice and Bob"
💬 "Show me the code quality report for this project since 2024-01-01"
💬 "What does each developer's work pattern look like on branch main?"
💬 "Give me an honest review of every contributor's strengths and weaknesses"
💬 "Is there a bus-factor risk in /path/to/my-project?"
```

### 中文

```
💬 "分析一下 /path/to/my-project 这个仓库"
💬 "帮我看看这个项目里每个开发者的提交习惯"
💬 "对比一下 Alice 和 Bob 的研发效率"
💬 "生成这个仓库的开发者画像报告"
💬 "这个项目的代码质量怎么样？"
💬 "从 2024 年 1 月开始，分析 main 分支的提交记录"
💬 "团队里谁的代码风格最好？谁需要改进？"
💬 "看看这个仓库有没有巴士因子风险"
```

### 日本語

```
💬 "このリポジトリの開発者を分析してください /path/to/my-project"
💬 "各開発者のコミット習慣を比較してください"
💬 "このプロジェクトのコード品質レポートを作成してください"
💬 "チームの開発効率を評価してください"
```

### 한국어

```
💬 "이 저장소의 개발자 프로필을 분석해 주세요 /path/to/my-project"
💬 "각 개발자의 커밋 습관을 비교해 주세요"
💬 "이 프로젝트의 코드 품질 보고서를 만들어 주세요"
💬 "팀의 개발 효율성을 평가해 주세요"
```

### Español

```
💬 "Analiza el repositorio en /path/to/my-project"
💬 "Compara los hábitos de commit de todos los desarrolladores"
💬 "Dame un informe de calidad del código de este proyecto"
💬 "¿Quién es el desarrollador más activo del equipo?"
```

### Français

```
💬 "Analyse le dépôt situé à /path/to/my-project"
💬 "Compare les habitudes de commit de chaque développeur"
💬 "Génère un rapport de qualité du code pour ce projet"
💬 "Qui est le contributeur le plus actif de l'équipe ?"
```

### Deutsch

```
💬 "Analysiere das Repository unter /path/to/my-project"
💬 "Vergleiche die Commit-Gewohnheiten aller Entwickler"
💬 "Erstelle einen Code-Qualitätsbericht für dieses Projekt"
💬 "Wer ist der aktivste Entwickler im Team?"
```

---

## ⚙️ Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| `repo_path` | Absolute path to the target Git repository | ✅ Yes | — |
| `authors` | Comma-separated display names (emails NOT accepted) | No | All contributors |
| `since` | Start date in ISO format (`YYYY-MM-DD`) | No | Full history |
| `until` | End date in ISO format (`YYYY-MM-DD`) | No | Full history |
| `branch` | Target branch to analyze | No | Active branch |

**What you get:** A structured Markdown report with a summary table, per-developer profiles (six-dimension radar scores, strengths/weaknesses, improvement suggestions), team comparison, and bus-factor risk alerts.

---

## Security Specification

> **All shell command parameters MUST be strictly validated before execution to prevent command injection attacks.**

### Dry-Run Mode (Recommended for First Use)

Before executing any commands, the agent SHOULD offer a **dry-run mode** that:

1. Collects and validates all parameters per the rules below
2. Constructs the full list of shell commands that *would* be executed
3. **Prints every command to the user for review WITHOUT executing any of them**
4. Waits for explicit user approval before proceeding to actual execution

To trigger dry-run mode, the user can say:
```
💬 "Show me the commands first before running them"
💬 "Do a dry run on /path/to/repo"
💬 "先列出要执行的命令，不要运行"
```

> This allows the user to verify that every command strictly matches the whitelist below.

### Command Whitelist (Only These Commands Are Allowed)

This skill **only permits the following predefined read-only git subcommands**. No other shell commands may be executed:

| Allowed Command | Purpose | Modifies Repo? |
|----------------|---------|----------------|
| `git -C <path> rev-parse --is-inside-work-tree` | Verify the path is a valid Git repository | ❌ Read-only |
| `git -C <path> rev-parse --show-toplevel` | Resolve the repository root when the user-supplied path is a sub-directory | ❌ Read-only |
| `git -C <path> shortlog -sn --all` | Get contributor list and commit counts | ❌ Read-only |
| `git -C <path> log ...` | Get commit history details (read-only flags only) | ❌ Read-only |
| `git -C <path> diff --stat ...` | Get change statistics | ❌ Read-only |

> Any git invocation that is not represented by one of the rows above MUST be rejected, even if it appears read-only. Adding a new command to the whitelist is a deliberate change to the skill's safety contract and requires updating both this table and the dry-run verification checklist.

**Strictly Prohibited Command Types:**
- ❌ Any write operations: `git push`, `git commit`, `git merge`, `git rebase`, `git reset`, `git checkout`, `git branch -d`
- ❌ Any non-git commands: `curl`, `wget`, `python`, `node`, `bash -c`, `sh`, `eval`, `rm`, `cp`, `mv`
- ❌ Any file writes or redirections: `>`, `>>`, `tee` (pipe `|` is only allowed to connect read-only text-processing tools: `cut`, `sort`, `uniq`, `awk`, `grep`, `wc`, `sed`, `head`)
- ❌ Any network operations: `git fetch`, `git pull`, `git clone`, `git remote`

> **If the AI agent attempts to execute a command outside the whitelist, the user should immediately reject execution.**

### Input Validation Rules (Must Be Completed Before Any Git Command)

1. **`repo_path` (Repository Path) Validation:**
   - Must be an absolute path (starting with `/`)
   - Must NOT contain any of these dangerous characters or substrings: `;`, `|`, `&`, `$`, `` ` ``, `(`, `)`, `>`, `<`, `\n`, `\r`, `$()`, `..`
   - Path must be a real, existing Git repository (verified via `git -C <path> rev-parse --is-inside-work-tree` returning `true`)
   - If validation fails, **immediately abort and report the error to the user — no subsequent commands may be executed**

2. **`author` (Author Name) Validation:**
   - Only allowed characters: letters (a-z A-Z), digits (0-9), spaces, hyphens (`-`), underscores (`_`), dots (`.`)
   - **The `@` symbol is NOT allowed** (email format is prohibited to align with privacy protection rules)
   - Regex whitelist: `^[a-zA-Z0-9 _.-]+$`
   - Maximum length: 128 characters
   - If input contains `@`, prompt the user to use the author's display name instead, then skip that author

3. **`since` / `until` (Date Parameters) Validation:**
   - Must match ISO date format: `^[0-9]{4}-[0-9]{2}-[0-9]{2}$`
   - If validation fails, ignore the parameter and warn the user

4. **`branch` (Branch Name) Validation:**
   - Only allowed characters: letters, digits, `/`, `-`, `_`, `.`
   - Regex whitelist: `^[a-zA-Z0-9/_.-]+$`
   - Must NOT contain the `..` substring
   - If validation fails, use the default branch and warn the user

### Privacy Protection Rules

- **Developer email addresses are NOT collected.** All git commands use only `%an` (author name) to identify developers, never `%ae` (author email).
- **`git shortlog` uses `-sn` instead of `-sne`** to avoid leaking email addresses.
- **The `authors` parameter only accepts display names, NOT email addresses.** Input validation rejects values containing `@`.
- **Note on `git --author` semantics (precise):** Git internally matches the supplied value against both author-name and author-email fields. This skill does NOT disable that matching at the Git level. Instead, it enforces an *input-side* guarantee: the `authors` parameter is rejected if it contains `@` and must conform to `^[a-zA-Z0-9 _.-]+$`. In practice this means user-supplied values cannot be email-shaped, so they will only meaningfully match the name field; however, this is a guarantee about *what we accept as input*, not a Git-level toggle that disables email matching. The agent MUST NOT describe email matching as "disabled".
- **Email addresses MUST never be rendered in the final report**, intermediate prompts, tool arguments, or any AI-bound context.
- **Commit subjects (`%s`) and full file paths emitted by `--name-only` are local-only data.** Some whitelisted git commands touch this raw text — for example `git log ... --name-only` (which emits full paths) and pipelines that immediately consume `%s` in the same pipe via local tools such as `awk '{print length}'` (used for message-length and keyword statistics). The agent MUST collapse them into numeric aggregates locally and discard the raw text immediately; raw subjects and full paths MUST NOT enter any AI prompt or tool argument. The agent MUST NOT construct any command that emits `%s` together with per-commit structured fields (hash, numstat, file names, etc.) in a single output, to avoid raw subjects being captured alongside structured data. The opt-in exceptions in "Sensitive Data Filtering Rules" remain the only way to surface (already-redacted, truncated) commit subjects in the user-facing report.

### Sensitive Data Filtering Rules (Mandatory)

> **Local-Only vs. Model-Bound data — definitions:**
>
> - **Local-only data** is the raw output of whitelisted git commands, including commit subjects (`%s`) and file paths produced by `--name-only`. It is read into the agent's local execution environment **for the sole purpose of computing aggregate metrics**, and MUST be discarded immediately afterward.
> - **Model-bound data** is the only category of data permitted in any prompt sent to the AI model. It consists exclusively of numeric counts, averages, ratios, percentages, file-extension histograms, hour/weekday histograms, and bucketed enumerations (e.g., `bug_fix_commits=12`).
>
> Raw commit message text, full commit subjects, full file paths, branch names containing free-form text, and any unredacted strings derived from commit history are **strictly local-only**. The agent MUST NOT place such strings in any AI prompt, system message, tool argument, or other off-host context.

Before sending **any** data to the AI model for analysis, the agent MUST apply the following filtering pipeline. Each step is mandatory and non-skippable:

1. **Commit messages — local-only processing:**
   - The agent runs the whitelisted `git log` command(s) that emit `%s` and pipes the output through local Unix utilities (`awk '{print length}'`, `grep -cE`, `wc -l`, etc.) to compute, for example, average length, keyword counts (`fix`, `feat`, `revert`), and conventional-commit compliance rate.
   - The intermediate raw text MUST NOT be retained in any variable, conversation buffer, or prompt that is sent to the AI model. Only the resulting numeric aggregates are forwarded.
   - **Default behavior:** the AI model receives no commit message text, full or partial.
   - **Opt-in exception:** if and only if the user explicitly requests to see specific commit messages, the agent MUST, in this order:
     1. Apply every redaction pattern in step 2 below to each candidate message,
     2. Truncate each redacted message to a maximum of 120 characters,
     3. Render the redacted, truncated messages **only in the final user-facing report**, never inside an intermediate AI prompt or tool call,
     4. Warn the user that commit messages may still contain sensitive context that automated patterns cannot fully detect.

2. **Automatic redaction of secret patterns (applied before any string crosses the local-only boundary, e.g. before display in the user-facing report):**
   - API keys / tokens: strings matching `(?i)(api[_-]?key|token|secret|password|credential|auth)[=:]\s*\S+`
   - AWS keys: `AKIA[0-9A-Z]{16}`
   - Private keys: `-----BEGIN .* PRIVATE KEY-----`
   - Connection strings: `(?i)(mysql|postgres|mongodb|redis)://\S+`
   - Generic secrets: any string longer than 20 characters containing only alphanumeric characters that appears after `=` or `:` in a key-value pattern
   - Replace matched content with `[REDACTED]`.

3. **Filename filtering — extension-only by default:**
   - The whitelisted `git log ... --name-only` invocation is permitted **only when its output is immediately reduced locally**, e.g. via `grep -oE '\.[^./]+$' | sort | uniq -c`, so that the agent retains only an extension histogram. The full file paths produced by `--name-only` are local-only data and MUST NOT be sent to the AI model.
   - For rework detection (which conceptually requires per-file grouping), the agent MUST hash or anonymize each path locally (e.g. compute a stable opaque ID such as `file_<sha1[:8]>`) before any per-file structure is forwarded; only the rework counts and the opaque IDs may be sent.
   - **Opt-in exception:** if the user explicitly requests file-level analysis, the agent MUST, before sending any path:
     1. Drop any path component matching `.env`, `.credentials`, `*secret*`, `*password*`, `*token*`, or `*.pem` / `*.key`,
     2. Apply the regex redactions from step 2 above to the remaining path,
     3. Warn the user that file paths can reveal internal project structure and customer information.

4. **Author display names:**
   - Author names are forwarded to the AI model only as opaque attribution labels for aggregate metrics. The agent MUST NOT ask the model to infer personality, performance, or worth from the name itself, and MUST NOT couple author names with raw commit subjects in any prompt.

### Repository Path Scope Rules

- The agent MUST only access the specific repository path provided by the user.
- The agent MUST NOT traverse parent directories (`..`) or access files outside the repository root.
- The agent MUST NOT list or read arbitrary files from the filesystem — only the whitelisted `git` commands targeting the validated repository are permitted.
- If the user provides a path to a subdirectory within a repository, the agent MUST resolve the repository root using the whitelisted command `git -C <path> rev-parse --show-toplevel`, inform the user of the resolved root, and obtain confirmation before proceeding.

### Enforcement Verification Protocol

Because this is an instruction-only skill (no executable code), safety guarantees depend on the AI agent correctly implementing the rules above. **Users SHOULD verify enforcement before trusting the skill on sensitive repositories.**

**Verification steps (run on a safe test repository first):**

1. **Dry-run test:** Ask the agent to analyze a test repo using dry-run mode. Verify that:
   - Every proposed command appears in the Command Whitelist table above
   - No commands use `%ae` (email format) or `-sne` flags
   - All user-supplied values (path, author, dates) are properly quoted

2. **Input validation test:** Deliberately provide invalid inputs and verify rejection:
   ```
   "Analyze /tmp/test; rm -rf /"          -> agent MUST reject (dangerous characters)
   "Profile author user@email.com"         -> agent MUST reject (@ not allowed)
   "Analyze since 2024-13-99"              -> agent MUST reject or warn (invalid date)
   "Analyze branch ../../etc/passwd"       -> agent MUST reject (.. not allowed)
   ```

3. **Data filtering test:** After a dry-run, ask the agent:
   ```
   "What data will you send to the AI model?"
   ```
   The agent should confirm it sends only aggregated metrics (counts, averages, percentages), NOT raw commit messages or full file paths.

4. **Redaction test:** If commit messages are requested, verify that:
   - Messages are truncated to <=120 characters
   - Patterns like `API_KEY=xxx` appear as `[REDACTED]`
   - Messages appear only in the final report, not in intermediate processing

> **If any verification step fails, do NOT use the skill on sensitive repositories.** Report the failure to the skill maintainer.

## Use Cases

- When users need an aggregate, repository-level view of commit cadence, churn, and rework signals to surface collaboration-process improvement areas
- When users want to compare team-wide patterns (not individuals) such as commit-message conventionality, weekend/late-night ratios, and bus-factor risk
- When users want to understand the visible-engagement distribution across the repository as a starting point for conversation, **not** as a verdict on individuals
- When users need a structured, data-driven artifact to facilitate retrospective discussions about workflow

### Out-of-Scope Use Cases (the agent MUST refuse)

- Performance reviews, calibration, ranking, hiring, firing, layoffs, compensation, or any HR action
- Producing rankings or judgments of individuals' worth, intelligence, or commitment
- Surveillance of specific employees without their knowledge or consent
- Analyzing repositories the user has not confirmed they have authority to inspect

## Core Principles

> **Install nothing, run no scripts.** All data collection is done exclusively through native git commands (`git log`, `git shortlog`, `git diff --stat`, etc.). The AI is responsible for interpretation and evaluation.

> **Security first.** All user inputs must pass the validation rules above before being incorporated into shell commands. Any validation failure must result in termination or graceful degradation — never skip validation.

## Workflow

### Step 1: Confirm Analysis Parameters

Confirm the following with the user (use defaults if not specified):

| Parameter | Description | Default |
|-----------|-------------|---------|
| **Repository Path** | Absolute path to the target Git repository | (Required) |
| **Target Authors** | Specific developers to analyze; leave blank for all | All contributors |
| **Date Range** | Start/end dates in ISO format | Full repository history |
| **Branch** | Target branch for analysis | Current active branch |

> **⚠️ Before executing Step 2, ALL parameters MUST be validated according to the "Security Specification" above. Parameters that fail validation MUST NOT be used in command construction.**

### Step 2: Data Collection (Pure Git Commands)

Execute the following git commands in sequence to collect raw data. **All commands run against the target repository directory — no dependencies need to be installed.**

> In the examples below, `<repo_path>`, `<author>`, etc. are placeholders for validated safe values from Step 1.

> 🔐 **Local-only boundary reminder.** Every command in this section emits raw text (commit subjects, file paths, etc.) that is classified as **local-only** under the Sensitive Data Filtering Rules. The pipes shown below (`| awk '{ print length }'`, `| grep -oE '\.[^./]+$'`, `| wc -l`, etc.) are mandatory: their job is to collapse raw text into aggregate numeric output **before** anything is forwarded to the AI model. The agent MUST NOT capture the raw upstream text into any model-bound variable, prompt, or tool argument. If a step's natural output would still contain raw text (e.g., the rework-detection log below), the agent MUST hash, bucket, or otherwise anonymize it locally before any further processing.

#### 2.1 Contributor Overview

```bash
# List all contributors with commit counts (no email to protect privacy)
git -C <repo_path> shortlog -sn --all
```

#### 2.2 Per-Author Commit Details

For each author to be analyzed, execute the following commands (append `--since`, `--until`, `<branch>` parameters if a date range or branch was specified):

```bash
# Per-commit metadata for cadence/size analysis (NO commit subject — privacy):
# hash, author name, ISO date, plus numstat (additions/deletions/path) per commit.
# IMPORTANT: %s (commit subject) is intentionally OMITTED from this command so that
# raw subjects never enter agent memory together with structured per-commit data.
# The %an (author name) and per-file numstat lines are local-only intermediates
# and MUST be reduced to aggregate counts/sums before being forwarded to the AI model.
# File paths emitted by --numstat are subject to the same path-redaction rules as
# --name-only output (see Sensitive Data Filtering Rules §3).
git -C <repo_path> log --author="<author>" --pretty=format:"%H|%an|%aI" --numstat

# Commit count per hour of day (for work habit analysis)
git -C <repo_path> log --author="<author>" --pretty=format:"%aI" | cut -c12-13 | sort | uniq -c | sort -rn

# Commit count per day of week (1=Mon, 7=Sun)
git -C <repo_path> log --author="<author>" --pretty=format:"%ad" --date=format:"%u" | sort | uniq -c | sort -rn

# Lines added/deleted summary
git -C <repo_path> log --author="<author>" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2 } END { printf "added: %s, deleted: %s\n", add, subs }'

# Commit message length distribution (LOCAL-ONLY pipeline).
# IMPORTANT: %s emerges raw on the left side of this pipe and MUST be consumed by
# `awk '{print length}'` immediately. The agent MUST NOT split this pipeline,
# capture the left-hand-side output, or reuse the raw %s text anywhere downstream;
# only the resulting per-commit length integers may be aggregated and forwarded.
git -C <repo_path> log --author="<author>" --pretty=format:"%s" | awk '{ print length }'

# File types touched
git -C <repo_path> log --author="<author>" --pretty=tformat: --name-only | grep -oE '\.[^./]+$' | sort | uniq -c | sort -rn | head -20

# Commits per day (for frequency analysis)
git -C <repo_path> log --author="<author>" --pretty=format:"%ad" --date=short | sort | uniq -c | sort -rn | head -20

# Recent rework detection: per-file modification frequency within 7-day windows.
# IMPORTANT: the raw output below contains commit subjects (%s) and full file paths
# and is LOCAL-ONLY. The agent MUST reduce it locally to (a) a per-author rework
# count and (b) an extension-level histogram BEFORE any value crosses into a model
# prompt. Replace each path with an opaque ID (e.g., file_<sha1[:8]>) if per-file
# grouping must be retained.
git -C <repo_path> log --author="<author>" --pretty=format:"%ad" --date=short --name-only | head -200
```

> Note: the rework-detection command above intentionally drops `%s` (commit subject) compared to a naive implementation, because subjects must remain local-only and are not needed for the rework metric (which is a count of how often a file is touched within a sliding window).

#### 2.3 Code Quality Signals

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

#### 2.4 Team-Level Data

```bash
# Files with only one contributor (bus factor risk)
git -C <repo_path> log --pretty=format:"%an" --name-only | sort | uniq -c | sort -rn | head -30

# Active date range per author
git -C <repo_path> log --author="<author>" --pretty=format:"%ad" --date=short | sort | sed -n '1p;$p'
```

### Step 3: AI Analysis & Evaluation

Based on the collected raw data, analyze each developer across the following **six dimensions**, assigning a score of 1–10 for each:

---

#### 📝 Dimension 1: Commit Habits

**Analysis Factors:**
- Total commit count, average daily commit frequency
- Average lines changed per commit (additions + deletions)
- Average commit message length and quality
- Merge commit ratio
- Frequency of large commits (>500 lines)

**Scoring Criteria:**
- 10: 2–5 daily commits, 50–200 lines each, clear and well-formatted messages
- 5: Inconsistent frequency, occasional giant commits, mixed message quality
- 1: Very few commits or frequent giant commits with one-word messages

---

#### ⏰ Dimension 2: Work Habits

**Analysis Factors:**
- Commit time distribution (peak hours)
- Weekend commit percentage
- Late-night coding ratio (22:00–04:59)
- Longest consecutive coding streak (days)
- Active days / total span days

**Scoring Criteria:**
- 10: Regular working hours, late-night/weekend ratio <10%, consistent and steady output
- 5: Some late-night/weekend commits, moderate rhythm fluctuations
- 1: Almost all commits at night/weekends, or extremely irregular patterns

> Note: Late-night/weekend coding is not inherently "bad," but persistent patterns may indicate process or resource issues.

---

#### 🚀 Dimension 3: Development Efficiency

**Analysis Factors:**
- Net code growth rate: (additions - deletions) / additions
- Code churn rate: deletions / additions
- Rework ratio: frequency of modifying the same file within 7-day windows
- Average daily output during active days

**Scoring Criteria:**
- 10: High net growth rate, churn rate <20%, low rework ratio, stable output
- 5: Moderate churn rate, some rework
- 1: Massive code deletions, frequent rework, highly volatile output

---

#### 🎨 Dimension 4: Code Style

**Analysis Factors:**
- Primary programming languages / file type distribution
- Conventional Commits compliance rate
- Whether commit messages reference issue numbers
- File modification focus (concentrated on a few modules vs. scattered)

**Scoring Criteria:**
- 10: >80% Conventional Commits compliance, messages reference issues, focused modifications
- 5: Partial compliance, occasionally scattered
- 1: Almost no compliance, meaningless messages

---

#### 🔍 Dimension 5: Code Quality

**Analysis Factors:**
- Bug fix commit ratio
- Revert commit frequency
- Large commit (>500 lines) ratio
- Frequency of test-related file modifications

**Scoring Criteria:**
- 10: Bug fix ratio <10%, no reverts, large commits <5%, test files modified
- 5: Bug fix 15–25%, few reverts, some large commits
- 1: Bug fix >30%, frequent reverts, many giant commits

---

#### 📊 Dimension 6: Visible-Activity Index (formerly "Engagement Index")

> **⚠️ Hard Usage Restriction — binding on the agent.** This index is a coarse macro-level signal of *visible Git activity only*. It is **NOT** a measure of engagement, dedication, productivity, or value, and the agent MUST refuse to characterize it as such. The agent MUST NOT use, present, or allow the user to use this index — alone or combined with other dimensions — as a basis for performance reviews, calibration, layoff or hiring decisions, compensation adjustments, ranking, or any other HR / personnel decision. If the user requests such usage, the agent MUST decline, explain the limitation, and offer to focus on aggregate workflow patterns instead.

> Note: This index reflects only what Git history makes visible (commit metadata). It is blind to design work, code review, mentoring, on-call duty, customer escalations, documentation, paired work attributed to a co-author, work pushed under a different identity, or any contribution that does not produce commits on the analyzed branch.

**Calculation Method (composite of the following signals, 0–100 scale, lower = higher visible Git activity; this is a workflow-pattern signal, not a performance signal):**

| Signal | Weight | Description |
|--------|--------|-------------|
| Very low daily commits (<0.3) | 25% | Visible commit cadence is low — may also indicate work happens elsewhere |
| Low active-day ratio (<30%) | 20% | Few days with commits across the analyzed span |
| Very low or negative net code growth | 20% | More lines deleted than added in the span |
| Short commit message length (avg <15 chars) | 15% | Subjects are short — note: short messages are not inherently bad |
| High churn rate + high rework rate | 20% | High edit-and-revise pattern in the analyzed span |

**Levels:**
- 0–20: Highly active — consider whether burnout risk exists
- 21–40: Steady participation, consistent output
- 41–60: Moderate participation, room for improvement
- 61–80: Low participation — check if there are non-code contributions not captured
- 81–100: Very low participation — recommend discussing with the individual to understand the full picture

> **Important:** This index is calculated solely from Git commit records and cannot reflect code reviews, architecture design, technical discussions, team mentoring, or other work that doesn't produce commits. A high score does NOT equal "slacking," and a low score does NOT equal "efficient." Please make judgments only after understanding the full context.

### Step 4: Generate Report

The final report MUST include the following structure:

#### 4.1 Summary Table

| Developer | Commits | Lines +/- | Daily Avg | Weekend% | Late-Night% | Bug Fix% | Churn Rate | Engagement | Overall Score |
|-----------|---------|-----------|-----------|----------|-------------|----------|------------|------------|---------------|
| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |

#### 4.2 Individual Developer Profiles

For each developer, output:

1. **Data Dashboard**: Key metrics for all six dimensions
2. **AI Commentary**: Serious, direct assessment of strengths and weaknesses (no sugarcoating)
3. **Improvement Suggestions**: Specific, actionable recommendations for each weakness
4. **Six-Dimension Radar Score**: 1–10 per dimension
5. **Overall Score**: Weighted average (Commit Habits 15%, Work Habits 15%, Dev Efficiency 25%, Code Style 15%, Code Quality 20%, Engagement Index inverse 10%)
6. **One-Line Summary**: A sharp, memorable sentence summarizing this developer

#### 4.3 Team Cross-Comparison

- Rankings across all dimensions
- Highlight best / worst performers
- Overall team health assessment
- Bus factor risk alerts

## Commentary Style Requirements

- **Serious and direct**: No sugarcoating, no hedging. Let the data speak — good is good, bad is bad.
- **Warm but firm**: Point out problems while providing a path to improvement. Critique the work, not the person.
- **Sharp but fair**: Like a senior Tech Lead conducting an annual Code Review — neither pulling punches nor being cruel.
- **Data-driven**: Every conclusion MUST be backed by corresponding data. No gut feelings.

## Important Notes

- All data collection uses only native `git` commands — **no pip packages, no Python/Node scripts installed or executed**
- **Required system binaries:** `git`, `cut`, `sort`, `uniq`, `awk`, `grep`, `sed`, `wc`, `head` — these must be available on the host (pre-installed on most Unix-like systems)
- **All user inputs MUST be validated per the "Security Specification" rules before execution** to prevent command injection attacks
- **Dry-run mode is recommended for first use** — review all commands before allowing execution
- **Enforcement verification:** Before using on sensitive repos, run the "Enforcement Verification Protocol" on a test repository to confirm your agent correctly implements all validation, whitelisting, and redaction rules
- **Sensitive data protection (binding):** Commit messages and full file paths are **local-only** data. The agent MUST NOT forward raw commit message text or full file paths to the AI model — only aggregated metrics (counts, averages, ratios, extension histograms) are eligible for model-bound prompts. Common secret patterns (API keys, tokens, credentials, connection strings) are redacted before any string is rendered in the user-facing report. See "Sensitive Data Filtering Rules" for binding enforcement.
- **Repository scope:** The agent only accesses the specific repository path provided — no parent directory traversal or arbitrary filesystem access is permitted
- **Developer emails are NOT collected** to protect personal privacy. Note on `git --author`: Git internally matches the supplied value against both name and email fields, so the agent enforces the `^[a-zA-Z0-9 _.-]+$` whitelist on `authors` precisely so that, in practice, only the name field can match. Users should be aware that this is a guarantee about *inputs we accept*, not a Git-level toggle that disables email matching.
- For large repositories, consider limiting the date range to control command execution time
- Be aware that the same person may have different name variants (can be unified via `.mailmap`)
- Timezone differences may affect work-hour analysis — use the timezone from the commit records
- The Visible-Activity Index is based solely on Git commit data and **does NOT reflect non-code contributions** (design, reviews, mentoring, etc.) — it MUST NOT be used for performance evaluation, ranking, or HR decisions

## Ethical Use Policy (binding on the agent)

Reports generated by this skill MUST adhere to the following principles. The agent MUST refuse requests that violate them:

1. **Workflow reference, NOT a decision-making basis.** Reports describe repository-level workflow patterns. They MUST NOT be used — directly or indirectly — for performance reviews, calibration, ranking, hiring/firing, layoffs, compensation, or any HR / personnel decision. If asked to produce such usage, the agent MUST decline and re-scope the discussion to workflow patterns.
2. **Consent & transparency.** When used in a team context, the user MUST inform analyzed contributors in advance. The agent SHOULD prompt the user to confirm this before generating per-individual breakdowns.
3. **Full context required.** Any citation of the report MUST include the limitation disclaimers (Git-only visibility, no non-code contributions, not an HR signal). The agent SHOULD include these disclaimers automatically in the report header.
4. **Critique workflow, not people.** Commentary MUST stay focused on observable workflow signals (e.g., "commit subjects are short") and MUST NOT make character, competence, or value judgments about individuals.
5. **Refuse weaponization.** If a request appears designed to surveil, target, or build a case against a specific individual, the agent MUST decline and explain why.
