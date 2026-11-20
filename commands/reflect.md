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
skill. Propose the smallest patch with evidence. Do not edit a skill without
approval.
