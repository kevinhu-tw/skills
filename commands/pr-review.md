---
description: "Review a PR, branch, diff, design, or repository with evidence"
argument-hint: "[pr-url | branch | path]"
subagent: false
---

Use the `pr-review` skill: load it if your agent has a skill tool, or read its
`SKILL.md`, and follow its instructions.

The user invoked `/pr-review` with these arguments:

$ARGUMENTS

An empty argument means the current branch against its base. A PR number or URL
means that PR. A path to a markdown file means a design review. A path to a
repository means a whole implementation review. Explain the
architecture first, then report findings by severity with path and line. Stay
read-only unless the user asks for fixes.
