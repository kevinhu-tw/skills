---
name: spec
description: Write or review a proposal or design spec, or review an ADR. Covers the problem, goals, non-goals, constraints, options, numbered decisions, interfaces, data flow, failure modes, migration, rollback, test plan, and commit-sized steps. Use when the user says write a spec, design this, write a proposal, review this design, review an ADR, or asks how to implement a feature before coding. For drafting a single ADR, use the adr skill. Stop for approval before implementation.
---

# Spec

A spec is a decision document, not an essay. It exists so an implementer can build
the change without guessing and a reviewer can disagree with a decision before
the code exists.

The skill has two modes:

1. Write a new ADR, proposal, or design spec.
2. Review an existing one against the code, the constraints, and its own claims.

In both modes, the output is a decision record with evidence, not a summary of
opinions.

## Input

- No argument: ask for the topic, the problem, and the constraints.
- A topic: write a new spec.
- A path: review that document.
- An existing decision: update it when it is the right home, otherwise create a
  proposal or a new ADR.

## Choose the document

Use the repository's existing convention first. Read `docs/adr`, `docs/rfcs`,
`docs/proposals`, `AGENTS.md`, and the README before creating a new file.

- ADR: one decision. Draft it with the `adr` skill; review it here. Accepted ADRs
  are historical records.
- Proposal: a larger change with options and a recommendation, written before the
  decision is final. It can be revised as the discussion changes.
- Design spec: the accepted design with enough detail to implement. It can be
  revised as implementation reveals new facts, but material changes need a
  decision ledger entry.

Prefer updating an existing document when the content belongs there. Do not
create a second record for a wording fix, an added consequence, or a missing
reference. If an accepted ADR's decision changes, create a new ADR that
supersedes it, mark the old one superseded, and link both. Do not rewrite history
silently.

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

- The problem in observable terms. What happens today, to whom, and how often?
- The success criteria. How will we know the change worked?
- The non-goals. What is explicitly out of scope?
- The constraints. Compatibility, performance, security, operations, cost, team,
  deadline, and anything that cannot change.
- The assumptions. What must be true for the design to hold?
- The open decisions. What must the user decide before implementation?

Ask only questions that block the design. Put the rest in the open questions
section with an owner and a default.

## Write the spec

Start with a one-page executive summary. Use formal headings, not question words
such as why, what, and how: Scope, Architecture, Design decisions, Workarounds,
Delivery plan, Risks. List the decisions as a short table. Then expand in this
order: Context, Goals and non-goals, Options and trade-offs, Design, Constraints
and workarounds, Test plan, Implementation plan. The summary is for the reader
who stops there; the rest carries the evidence.

Use this structure unless the repository has a stricter template.

```markdown
# <Title>

Status: draft | proposed | accepted | superseded
Date: <YYYY-MM-DD>
Owners: <names>
Links: <issue, prior ADR, PR, design discussion>

## Executive summary

**Scope:** <the problem in observable terms, and what this change does and does
not cover.>

**Architecture:** <the end-to-end path and the mechanism: components, entry
points, and artifacts.>

**Design decisions:**

| ID | Decision | Proposed |
| --- | --- | --- |
| D1 | <what must be decided> | <default> |

**Workarounds:** <hacks, sharp edges, and facts that change how the design is
read.>

## Problem

<Observable current behavior, who is affected, and why it matters.>

## Goals

- <A measurable outcome.>
- <A measurable outcome.>

## Non-goals

- <What this change will not do.>

## Constraints

- <Compatibility, performance, security, operations, cost, team, deadline.>

## Current behavior

<How the system works today, with file references. Include the workaround.>

## Options

### Option A: <name>

<How it works. Trade-offs. Cost. Risk. Reversibility.>

### Option B: <name>

<How it works. Trade-offs. Cost. Risk. Reversibility.>

## Decision

<The chosen option and the reason. What would make this decision wrong?>

## Decision ledger

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
does not apply, remove it and say why in the decision ledger.

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
implement is a liability. A spec that leaves the hard decisions open is worse.

Every requirement must be testable. Replace vague goals with a command, a metric,
an observable state, or a test assertion. "Fast", "robust", and "clean" are not
requirements until they have a threshold.

## Decision ledger

Every material decision gets an entry:

- ID, so the implementation and review can refer to it.
- The decision in one sentence.
- The chosen option.
- The alternatives and why they lost.
- The consequence, including what becomes harder.
- The status: open, decided, superseded.

Open questions get an owner and a default. If the user does not answer, the
default is what the implementer will do. No silent assumptions.

If a decision changes during implementation, add a new row or mark the old one
superseded. Do not edit the record as if the earlier choice never existed.

## Review a spec

Read the document and the code it references. Then check:

- The executive summary uses formal headings: scope, architecture, design
  decisions, and workarounds or risks. No why, what, or how labels.
- The expansion covers context, options and trade-offs, and workarounds.
- The problem is observable, not a solution in disguise.
- Goals are measurable, and non-goals are explicit.
- Constraints are real, not aspirational.
- At least two options were considered, with honest trade-offs.
- The chosen option follows from the constraints and the evidence.
- Every material decision has a consequence and a rollback.
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
Fix: <the section or decision that must change>.
```

End with one verdict: approve, revise, or reject, and the top three changes.

## Stop for approval

Present the spec, the decision ledger, and the open questions. Stop.

Do not write code, edit production files, or open a PR until the user approves the
spec. If the user asks to implement, confirm the approved decisions and hand off
to the implementation flow.

If the user asks for a smaller step, propose the smallest decision that unblocks
implementation. Do not turn the request into a full design program.

## Guardrails

- Do not invent requirements, constraints, or user intent.
- Do not hide a trade-off in a recommendation.
- Do not create a new document when an existing one is the right home.
- Do not rewrite an accepted decision silently. Supersede it.
- Do not write a vague architecture essay. Every section must change what the
  implementer does.
- Do not over-specify code that is cheap to change during implementation.
- Do not use dashes as punctuation.
- Do not use question words as headings. Use Scope, Architecture, Design
  decisions, Workarounds, Risks.
- Stop for approval before implementation.
