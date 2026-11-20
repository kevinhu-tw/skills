---
description: "Reflect on a task and propose skill updates"
argument-hint: "[skill | task | time window]"
subagent: false
---

Use the `reflect` skill: load it if your agent has a skill tool, or read its
`SKILL.md`, and follow its instructions.

The user invoked `/reflect` with these arguments:

$ARGUMENTS

An empty argument means the current session. A skill name means reflect on that
skill. An explicit workflow change is approval to apply the smallest patch and
report the diff. An exploratory change is a proposal, so ask before editing. If
the message also contains a task, finish it first unless the change affects it.
