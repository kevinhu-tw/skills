# Skills

Reusable engineering skills for coding agents. Each skill is a `SKILL.md` file
under `skills/`; the installer links it into the directories OpenCode, Claude
Code, Cursor, and Codex read.

## repo-quiz

An adaptive oral exam over a codebase. It maps the repository, writes an
evidence-backed answer key before each question, asks one question at a time,
grades against the code, adapts the difficulty, and ends with a debrief.

It tests architecture, flow, invariants, failure modes, configuration, design
rationale, and implementation nuance. The skill keeps its question bank and
grades in the session temp directory, never in the repository.

Invoke it with a topic or with the current repository:

```text
/quiz me about the cli workflow of decoy
/quiz me about the fault injector
/quiz
```

`/quiz` is a convenience command for OpenCode and Claude Code. Cursor and Codex
invoke the skill directly.

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
```

The default is a symlink, so edits in this clone update the installed skill.
`--copy` is for agents or filesystems that do not follow symlinks. An existing
destination is not replaced without `--force`. Symlinks point at this clone;
reinstall after moving it.

## Where it installs

| Agent | Skill | Command | Invocation |
| --- | --- | --- | --- |
| OpenCode | `~/.config/opencode/skills/repo-quiz` | `~/.config/opencode/commands/quiz.md` | `/quiz me about <topic>` |
| Claude Code | `~/.claude/skills/repo-quiz` | `~/.claude/commands/quiz.md` | `/quiz me about <topic>` or `/repo-quiz` |
| Cursor | `~/.agents/skills/repo-quiz` | none | `/` then select `repo-quiz` |
| Codex | `~/.agents/skills/repo-quiz` | none | `/skills` then select `repo-quiz`, or `$repo-quiz` |

Cursor and Codex share `~/.agents/skills`. A project install uses `.opencode/`,
`.claude/`, and `.agents/` under the current directory.

OpenCode also reads the legacy `~/.config/opencode/skill` directory. If an older
copy of `repo-quiz` is there, remove it so OpenCode loads the installed version.

## Layout

```text
skills/
  repo-quiz/
    SKILL.md
commands/
  quiz.md
install.sh
tests/
  install_test.sh
```

Add a skill under `skills/<name>/SKILL.md`. Add a command under
`commands/<name>.md`. The installer picks up every skill directory and command
file; no per-skill edit is needed.

## Verify

The install test uses a temporary `--dest` and does not touch your home
directory:

```bash
./tests/install_test.sh
```

Local checks used for this repository:

```bash
./tests/install_test.sh
./install.sh --target all --dry-run
```

## Notes

- The skill is read-only. It never edits the repository.
- The `/quiz` command drops a leading `me` and `about`, so
  `/quiz me about the cli workflow of decoy` scopes the quiz to
  `the cli workflow of decoy`.
- The skill is portable across agents: it uses `CLAUDE.md`, `AGENTS.md`, tests,
  decision records, and code as evidence, and does not depend on one agent's
  tools.
