# Skills

Reusable engineering skills for coding agents. Each skill is a `SKILL.md` file
under `skills/`; the installer links it into the directories OpenCode, Claude
Code, Cursor, and Codex read.

## Skills

| Skill | Command | What it does |
| --- | --- | --- |
| `repo-quiz` | `/quiz` | Adaptive oral exam over a repo or topic, graded against the code |
| `pr-create` | `/pr-create` | Validate a branch, self-review the diff, and open or update a PR |
| `pr-review` | `/pr-review` | Explain a change, then review architecture, design, implementation, and security |
| `spec` | `/spec` | Write or review an ADR, proposal, or design spec that directs implementation |
| `reflect` | `/reflect` | Turn corrections into the smallest useful skill patch |

### repo-quiz

An adaptive oral exam over a codebase. It maps the repository, writes an
evidence-backed answer key before each question, asks one question at a time,
grades against the code, adapts the difficulty, and ends with a debrief.

It tests architecture, flow, invariants, failure modes, configuration, design
rationale, and implementation nuance. The skill keeps its question bank and
grades in the session temp directory, never in the repository.

```text
/quiz me about the cli workflow of decoy
/quiz me about the fault injector
/quiz
```

### pr-create

Takes a branch from "works on my machine" to a reviewable pull request. It runs
the project's format, lint, build, unit, and end-to-end gates, gathers exact
testing evidence, self-reviews the final diff, and writes the PR body in a fixed
format: Summary, What changed, Why, Implications, Reviewer focus, Testing, and
Gotchas.

The PR body is for reviewers. The internal report is for the user and carries
worktree state, design decisions, conflicts, and deferred items. The skill never
mixes the two audiences.

```text
/pr-create
/pr-create 7
```

### pr-review

Explains the architecture and the change before judging it, then reviews:

- Architecture: boundaries, dependency direction, interfaces, state ownership,
  duplication, and fit with existing patterns.
- Design: invariants, lifecycle, concurrency, idempotency, failure modes,
  migration, rollback, operability, and compatibility.
- Implementation: correctness, edge cases, resource leaks, tests, naming, dead
  code, and comments versus behavior.
- Security: input validation, injection, path traversal, secrets, permissions,
  supply chain, and unsafe defaults.
- Claims versus behavior: the PR body, comments, docs, and tests that say more
  than the code does.

Findings are ranked by severity and cite `path:line`. The skill is read-only by
default.

```text
/pr-review https://github.com/org/repo/pull/7
/pr-review my-branch
/pr-review docs/adrs/0014-presenter-replaces-gpu-subtrees.md
```

### spec

Writes and reviews ADRs, proposals, and design specs. A spec is a decision
document, not an essay. It must let an implementer build without guessing.

The skill covers the problem, goals, non-goals, constraints, current behavior,
options, numbered decisions, interfaces, data flow, state, configuration, errors,
concurrency, security, observability, migration, rollback, test plan, and a
commit-sized implementation plan.

It chooses the existing document when one is the right home. It numbers every
material decision, gives each open question an owner and a default, and stops for
approval before implementation.

```text
/spec
/spec typed decision training
/spec review docs/proposals/registry-auth.md
```

### reflect

Turns a correction into a durable skill change. It looks for repeated
corrections, missing steps, ambiguous instructions, wrong triggers, stale
references, and output mismatches, then applies or proposes the smallest patch.

An explicit change ("from now on", "going forward", "next time", "always",
"never", "remember this", "make this the default") is approval to apply the
patch. An exploratory change ("maybe we should", "what do you think") gets a
proposal and one question.

It prefers editing an existing skill over creating a new one. It only creates a
new skill when the loop is distinct, recurring, and has a stable trigger, input,
output, and stop condition.

```text
/reflect
/reflect pr-create
/reflect this session
```

### Automatic trigger

OpenCode can attach `reflect` from a prompt hook. The hook matches durable
workflow phrases, attaches the skill, and appends a one-turn directive. It does
nothing for ordinary prompts. Install and configure it:

```bash
./install.sh --target opencode --with-trigger
```

Then add the installed plugin to `~/.config/opencode/opencode.json` and restart
OpenCode:

```json
{
  "plugins": ["./plugins/reflect-trigger"]
}
```

The path is relative to the config directory. The installer symlinks the plugin
by default; `--copy` copies it. `--with-trigger` requires `--target opencode` or
`--target all`.

Claude Code, Cursor, and Codex have no shared prompt hook. There the skill
description is the trigger. For a stronger fallback, append
`templates/agents-snippet.md` to your global `AGENTS.md` or `CLAUDE.md`.

## Install

```bash
git clone git@github.com:kevinhu-tw/skills.git
cd skills
./install.sh --target all
```

Use `--scope project` inside a repository to install into that repository
instead of your home directory:

```bash
/path/to/skills/install.sh --target all --scope project
```

Other options:

```bash
./install.sh --target opencode
./install.sh --target claude
./install.sh --target cursor
./install.sh --target codex
./install.sh --target all --copy
./install.sh --target all --dry-run
./install.sh --target all --dest /tmp/skills-test
./install.sh --target opencode --with-trigger
```

The default is a symlink, so edits in this clone update the installed skills.
`--copy` is for agents or filesystems that do not follow symlinks. An existing
destination is not replaced without `--force`. Symlinks point at this clone;
reinstall after moving it.

## Where it installs

| Agent | Skills | Commands | Invocation |
| --- | --- | --- | --- |
| OpenCode | `~/.config/opencode/skills/<skill>` | `~/.config/opencode/commands/<command>.md` | `/pr-create`, `/pr-review`, `/spec`, `/reflect`, `/quiz` |
| OpenCode trigger | `~/.config/opencode/plugins/reflect-trigger` | none | automatic on durable workflow phrases |
| Claude Code | `~/.claude/skills/<skill>` | `~/.claude/commands/<command>.md` | the same commands, or `/<skill>` |
| Cursor | `~/.agents/skills/<skill>` | none | `/` then select the skill |
| Codex | `~/.agents/skills/<skill>` | none | `/skills` then select the skill, or `$<skill>` |

Cursor and Codex share `~/.agents/skills`. A project install uses `.opencode/`,
`.claude/`, and `.agents/` under the current directory.

OpenCode also reads the legacy `~/.config/opencode/skill` directory. If an older
copy of a skill is there, remove it so OpenCode loads the installed version.

## Layout

```text
skills/
  repo-quiz/
    SKILL.md
  pr-create/
    SKILL.md
  pr-review/
    SKILL.md
  spec/
    SKILL.md
  reflect/
    SKILL.md
commands/
  quiz.md
  pr-create.md
  pr-review.md
  spec.md
  reflect.md
plugins/
  opencode/
    reflect-trigger/
      index.ts
      patterns.mjs
templates/
  agents-snippet.md
install.sh
tests/
  install_test.sh
  reflect_trigger_test.mjs
```

Add a skill under `skills/<name>/SKILL.md`. Add a command under
`commands/<name>.md`. The installer picks up every skill directory and command
file; no per-skill edit is needed.

## Verify

The install test uses a temporary `--dest` and covers every skill and command in
the repository:

```bash
./tests/install_test.sh
```

Local checks used for this repository:

```bash
./tests/install_test.sh
node tests/reflect_trigger_test.mjs
./install.sh --target all --dry-run
./install.sh --target opencode --with-trigger --dry-run
```

## Skill conventions

- One skill owns one recurring loop. Do not build a single "engineering" skill
  with modes for everything.
- A skill is self-contained. It may mention another skill, but it must work
  without it.
- Cite evidence: a file and line, a command and output, or a primary source.
- Separate reviewer-facing output from internal context.
- Verify from a clean state when the project expects it. Never report an unrun
  check as a pass.
- Stop at approval gates and before destructive actions.
- Commands are thin. The skill owns the contract; the command only passes the
  argument.
- Write against `git`, `gh`, and the project's own commands, not one agent's
  private tools.
- Do not use dashes as punctuation.

## Notes

- `pr-create` and `pr-review` use `gh`. It must be authenticated for the
  repository you are working on.
- `spec` writes a document only when asked and stops for approval before
  implementation.
- `reflect` applies an explicit workflow change and proposes an exploratory one
  before editing a skill. It does not rewrite the library on its own.
- `repo-quiz` is read-only. It never edits the repository.
- The `/quiz` command drops a leading `me` and `about`, so
  `/quiz me about the cli workflow of decoy` scopes the quiz to
  `the cli workflow of decoy`.
