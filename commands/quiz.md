---
description: "Quiz me on a repo or a topic inside it"
argument-hint: "[me about <topic>]"
subagent: false
---

Use the `repo-quiz` skill: load it if your agent has a skill tool, or read its
`SKILL.md`, and follow its instructions.

The user invoked `/quiz` with these arguments:

$ARGUMENTS

Drop a leading `me`; then drop a leading `about`. The remainder is the scope. If
nothing remains, use the current repo. Start the session contract in one line,
then ask Q1.
