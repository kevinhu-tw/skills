---
description: "Write or review an implementation spec"
argument-hint: "[ADR | topic | path]"
subagent: false
---

Use the `spec` skill: load it if your agent has a skill tool, or read its
`SKILL.md`, and follow its instructions.

The user invoked `/spec` with these arguments:

$ARGUMENTS

An empty argument means ask for the accepted decision or ADR, the code to change,
and the constraints. A topic or ADR means write an implementation plan. A path
means review that spec. Read the accepted ADRs first, number the implementation
decisions, state the non-goals, and stop for approval before implementation. For
the decision record, use `adr`.
