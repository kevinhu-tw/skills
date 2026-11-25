---
name: spec
description: Write or review an implementation spec that an AI agent can execute. Reads the accepted ADRs and turns them into interfaces, data flow, state, errors, tests, and commit-sized steps. Use when the user says write an implementation spec, plan the implementation, turn this ADR into a plan, or asks how to build an approved design. For recording a decision, use the adr skill. Stop for approval before implementation.
---

# Spec

A spec is an execution document, not an essay. It exists so an AI agent can
produce the code without guessing and a reviewer can check the plan against the
accepted decisions.

The skill has two modes:

1. Write an implementation spec from accepted decisions.
2. Review an implementation spec against the code and the ADRs it cites.

In both modes, the output is a plan with evidence, not a summary of opinions.

## Relationship to ADRs

An ADR records a decision and its evidence. A spec records how to execute that
decision. Read the accepted ADRs first and cite them by number. Do not record,
change, or re-litigate an architecture decision in a spec. If a required decision
is missing, stop and draft an ADR with the `adr` skill.

## Input

- No argument: ask for the accepted decision or ADR, the code to change, and the
  constraints.
- A topic or ADR: write an implementation spec.
- A path: review that spec.
- An existing spec: update it. If the decision changed, update the ADR first.

## Choose the document

Use the repository's existing convention first. Read `docs/adrs`, `docs/adr`,
`docs/rfcs`, `docs/proposals`, `AGENTS.md`, and the README before creating a new
file.

- ADR: records one decision and its evidence. Use the `adr` skill. Accepted ADRs
  are historical records.
- Implementation spec: the plan an AI agent follows to produce code. This skill.
  It cites the ADRs it executes and does not replace them.

Prefer updating an existing spec when the content belongs there. Do not create a
second plan for a wording fix, an added consequence, or a missing reference. If
an accepted ADR's decision changes, create a new ADR that supersedes it, then
update the spec. Do not rewrite history silently.

Do not create a new document when an existing one is the right home. File sprawl
is a design failure.

## Before writing

Read enough to design against reality:

- The repository instructions, README, and contribution guide.
- The relevant code, tests, configuration, deployment, and CLI or API surface.
- Prior ADRs and proposals that touch the same boundary.
- Open issues, incidents, and review comments that explain the pain.
- The current behavior, including the workaround the change replaces.

Then state:

- The ADR or decision this spec executes.
- The code surface to change: packages, commands, APIs, state, and tests.
- The acceptance checks the code must pass. How will we know it works?
- The non-goals. What is explicitly out of scope?
- The constraints. Compatibility, performance, security, operations, cost, team,
  deadline, and anything that cannot change.
- The assumptions. What must be true for the plan to hold?
- The implementation choices still open, with a default.

Ask only questions that block the plan. Put the rest in the open questions
section with an owner and a default.

## Write the spec

Start with a one-page implementation summary. Use formal headings, not question
words such as why, what, and how: Scope, Execution, Implementation decisions,
Workarounds, Delivery plan, Risks. List the decisions as a short table. Then
expand in this order: Context and ADRs, Goals and non-goals, Implementation
options, Design, Constraints and workarounds, Test plan, Implementation plan.
The summary is for the reader who stops there; the rest carries the detail an
agent needs to code.

Use this structure unless the repository has a stricter template.

```markdown
# <Title>

Status: draft | approved | superseded
Date: <YYYY-MM-DD>
ADRs: <ADR numbers this plan executes>
Owners: <names>
Links: <issue, ADR, PR, design discussion>

## Implementation summary

**Scope:** <the decision this plan executes, and what the change does and does
not cover.>

**Execution:** <the end-to-end path and mechanism: components, entry points, and
artifacts.>

**Implementation decisions:**

| ID | Decision | Proposed |
| --- | --- | --- |
| D1 | <what must be decided> | <default> |

**Workarounds:** <hacks, sharp edges, and facts that change how the design is
read.>

## Context and ADRs

<The accepted ADRs this plan executes, the current behavior, and the code that
must change.>

## Goals

- <A measurable outcome.>
- <A measurable outcome.>

## Non-goals

- <What this change will not do.>

## Constraints

- <Compatibility, performance, security, operations, cost, team, deadline.>

## Current behavior

<How the system works today, with file references. Include the workaround.>

## Implementation options

<Only choices the ADR left open. Architecture options belong in the ADR.>

### Option A: <name>

<How it works. Trade-offs. Cost. Risk. Reversibility.>

### Option B: <name>

<How it works. Trade-offs. Cost. Risk. Reversibility.>

## Chosen implementation

<The implementation path and the ADR it executes. What would make this plan
wrong?>

## Implementation decisions

| ID | Decision | Choice | Alternatives | Consequence | Status |
| --- | --- | --- | --- | --- | --- |
| D1 | <what was decided> | <choice> | <alternatives> | <what follows> | decided |
| D2 | <what is still open> | <default> | <alternatives> | <what follows> | open |

## Design

### Boundaries and packages

<Which package, process, or layer owns the change. Dependency direction.>

### Interfaces and data types

<Signatures, structs, enums, aliases, or schemas. Name the real types.>

### Data flow

<The path through the system. Include a sequence or state diagram when useful.>

### State and lifecycle

<What state exists, who owns it, and how it is created, read, changed, and
deleted. Include retries, replacement, and reconciliation.>

### Configuration

<Keys, flags, environment variables, defaults, validation, and precedence.>

### CLI and API

<Commands, arguments, output, exit codes, endpoints, and compatibility.>

### Errors and failure modes

<What can fail, what the caller sees, what is retried, what is rolled back, and
what is left behind.>

### Concurrency and idempotency

<Races, ordering, locks, timeouts, context cancellation, and safe repetition.>

### Security

<Trust boundaries, input validation, secrets, permissions, and unsafe defaults.>

### Observability

<Logs, metrics, status, events, and what an operator can diagnose.>

### Migration and rollback

<Schema, config, state, and API migration. How to roll back without data loss.>

## Test plan

- Happy path: <test name and assertion>.
- Failure: <test name and assertion>.
- Boundary: <test name and assertion>.
- Concurrency or migration: <test name and assertion>.
- Manual or end-to-end: <environment, command, expected result>.

## Implementation plan

1. <Commit-sized step. Gate: format, lint, unit test.>
2. <Commit-sized step. Gate: format, lint, unit test.>
3. <Commit-sized step. Gate: end-to-end or manual check.>

## Open questions

| ID | Question | Owner | Default if unanswered |
| --- | --- | --- | --- |
| Q1 | <question> | <name> | <default> |

## References

- <Code, ADR, issue, upstream documentation.>
```

Adapt the headings to the repository. Do not leave empty sections. If a section
does not apply, remove it and say why in the implementation decisions.

## Detail level

Specify what changes an interface, a contract, a state transition, a security
boundary, or a user-visible behavior. Leave the rest to the implementer.

Name real things where they are known:

- Packages and file paths.
- Types, functions, and signatures.
- Config keys, flags, environment variables, and defaults.
- Error messages and exit codes.
- State names and transitions.
- Test names and assertions.

Do not write a line-by-line implementation. A spec that leaves no room to
implement is a liability. A spec that leaves the hard implementation choices open
is worse.

Every requirement must be testable. Replace vague goals with a command, a metric,
an observable state, or a test assertion. "Fast", "robust", and "clean" are not
requirements until they have a threshold.

## Implementation decisions

Every material implementation choice gets an entry:

- ID, so the code and review can refer to it.
- The choice in one sentence.
- The alternatives and why they lost.
- The consequence, including what becomes harder.
- The status: open, decided, superseded.

Architecture decisions belong in an ADR, not here. If an implementation choice
changes an accepted decision, stop and supersede the ADR.

Open questions get an owner and a default. If the user does not answer, the
default is what the implementer will do. No silent assumptions.

If an implementation choice changes during the work, add a new row or mark the
old one superseded. Do not edit the record as if the earlier choice never
existed.

## Review a spec

Read the document, the code it references, and the ADRs it cites. Then check:

- The implementation summary uses formal headings: scope, execution,
  implementation decisions, and workarounds or risks. No why, what, or how
  labels.
- The expansion covers context and ADRs, implementation options, and workarounds.
- The spec cites the accepted ADRs it executes and does not re-decide them.
- Goals are measurable, and non-goals are explicit.
- Constraints are real, not aspirational.
- Implementation options were considered where the ADR left a choice.
- The plan follows the accepted ADRs and the constraints.
- Every implementation choice has a consequence and a rollback.
- Interfaces, data flow, state, errors, concurrency, and failure modes are
  specified.
- Security and operability are covered.
- Migration, compatibility, and rollout are covered.
- The test plan covers the happy path, a failure, a boundary, and the migration.
- The implementation plan is commit sized and ordered.
- Every requirement is testable.
- Every open question has an owner and a default.
- Nothing in the document depends on an unstated fact.

Report findings by severity, highest first. Use section references, not line
numbers, unless the document is stable. Each finding needs:

```text
[medium] Design, State and lifecycle: <what is missing or wrong>.
Consequence: <what the implementer will have to guess, or what will break>.
Fix: <the section or implementation choice that must change>.
```

End with one verdict: approve, revise, or reject, and the top three changes.

## Stop for approval

Present the spec, the implementation decisions, and the open questions. Stop.

Do not write code, edit production files, or open a PR until the user approves the
spec. If the user asks to implement, confirm the approved decisions and hand off
to the implementation flow.

If the user asks for a smaller step, propose the smallest implementation choice
that unblocks the work. Do not turn the request into a full design program.

## Guardrails

- Do not invent requirements, constraints, or user intent.
- Do not hide a trade-off in a recommendation.
- Do not create a new document when an existing one is the right home.
- Do not change an accepted decision in a spec. Supersede the ADR first.
- Do not turn a spec into an ADR. Decisions and evidence belong in the ADR.
- Do not write a vague architecture essay. Every section must change what the
  implementer does.
- Do not over-specify code that is cheap to change during implementation.
- Do not put machine-specific local environment values, such as personal hostnames, Docker context names, or home paths, into specifications or implementation plans unless the user explicitly requests them. Prefer portable requirements and generic configuration interfaces.
- Do not use dashes as punctuation.
- Do not use question words as headings. Use Scope, Execution, Implementation
  decisions, Workarounds, Risks.
- Stop for approval before implementation.
