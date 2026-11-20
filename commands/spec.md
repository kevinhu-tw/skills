---
description: "Write or review a proposal or design spec"
argument-hint: "[topic | path]"
subagent: false
---

Use the `spec` skill: load it if your agent has a skill tool, or read its
`SKILL.md`, and follow its instructions.

The user invoked `/spec` with these arguments:

$ARGUMENTS

An empty argument means ask for the topic, the problem, and the constraints. A
path means review that document. Choose the existing document when one is the
right home. Number the decisions, state the non-goals, and stop for approval
before implementation. For drafting a single ADR, use `adr`.
