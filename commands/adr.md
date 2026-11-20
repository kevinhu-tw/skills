---
description: "Draft one engineering ADR"
argument-hint: "[decision | topic | path]"
subagent: false
---

Use the `adr` skill: load it if your agent has a skill tool, or read its
`SKILL.md`, and follow its instructions.

The user invoked `/adr` with these arguments:

$ARGUMENTS

An empty argument means ask for the decision in one sentence, the forces, and
the alternatives. A topic means draft a new ADR. A path to a proposed ADR means
revise it; a path to an accepted ADR means draft a superseding one. Read the
repository's ADR guide and index first. Stop before code.
