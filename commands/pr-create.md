---
description: "Prepare a branch and open or update a pull request"
argument-hint: "[pr-number | pr-url]"
subagent: false
---

Use the `pr-create` skill: load it if your agent has a skill tool, or read its
`SKILL.md`, and follow its instructions.

The user invoked `/pr-create` with these arguments:

$ARGUMENTS

An empty argument means the current branch. A PR number or URL means update that
PR. Infer the base branch from the repository or the existing PR. Run the
project's gates, self-review the diff, and write the body in the skill's format.
Do not open a ready PR with a failing gate. Keep the internal report separate from
the PR body.
