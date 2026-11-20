---
name: adr
description: Draft one engineering Architecture Decision Record in the repository's existing ADR system. Reads the ADR guide, index, prior decisions, code, and evidence; writes one proposed record and updates the index; stops before implementation. Use when the user says write an ADR, draft an ADR, record this decision, add a decision record, or invokes /adr. For a proposal or design spec, use spec.
---

# ADR

One decision, one record. The job is to make a decision reviewable and durable,
not to write a design document. Use the `spec` skill for a proposal, a design
spec, or an implementation plan.

## Input

- No argument: ask for the decision in one sentence, the forces, and the
  alternatives. Stop.
- A topic: draft a new ADR.
- A path to a proposed ADR: revise it in place.
- A path to an accepted ADR: do not edit it; draft a superseding ADR.

## Locate the record system

Read the repository instructions, README, contribution guide, and the ADR
directory. Common names are `docs/adrs/`, `docs/adr/`, `adr/` and `decisions/`.
Read any ADR guide, template, and index before writing.

The repository's guide wins over the default shape in this skill. If no ADR
system exists, ask whether to create one. Do not create a parallel system.

Read the index, find the next free number, and read every ADR that touches the
same boundary. Do not draft against an unread prior decision.

## Decide the shape

- One ADR is one decision. If the request contains several independent choices,
  propose a split and draft the first.
- Status is `proposed` unless the user says it is accepted or the repository uses
  another vocabulary. Do not mark an ADR accepted without explicit approval.
- If an accepted ADR's decision changes, draft a new ADR that supersedes it,
  wholly or in part. Do not edit the accepted body.
- If an existing proposed ADR is the right home, revise it. Do not create a
  second record for a wording fix, an added consequence, or a missing reference.

## Gather evidence

Read the code, tests, configuration, research notes, issues, and prior ADRs that
the decision depends on. For every claim about upstream behavior, hardware, or a
third party, cite the source or mark it **UNVERIFIED**. Pin code citations to a
commit when line numbers are used. A live result records the date, environment,
command, and result.

Do not invent a requirement, a constraint, or a user intent. If a missing fact
blocks the decision, ask one question and stop.

## Draft the record

Use the repository's template. If it has none, use this shape:

```markdown
# NNNN: <the decision>

- **Status:** proposed
- **Date:** YYYY-MM-DD

## Context

<What exists today, what changed, and which prior ADRs constrain the answer.>

## Decision

<The commitment, named as a mechanism. Number the items when there are several.>

## Consequences

<What follows, including applicable cost, migration, limits, and what stops
working. Add one implementation-status line when code and status differ.>

## Alternatives considered

<Each serious alternative and why it lost.>

## Verification

<Optional: date, environment, command, result.>

## Open points

<Optional while proposed. Name the trigger that closes each one.>

## References

<Research notes with sections, code paths pinned to a commit, issues, related
ADRs.>
```

Follow these rules:

- The title states the decision, not the topic.
- Context carries the forces and evidence, not the solution.
- Decision names mechanisms, not intentions. It is testable against code, a
  node, or a named acceptance criterion.
- Consequences covers cost, migration, limits, and follow-up work.
- Every alternative has a real rejection reason.
- References cite the owning file for any copied shape. Do not copy a table,
  schema, or catalog that a source file owns.
- Do not add an implementation plan. The ADR records the choice; the plan records
  the order.

## Update the index

Add one row to the index in the same change. The status is exact. The title is a
short summary. If the repository keeps drift notices, put non-semantic notices
in the index, not in the ADR body.

## Output contract

Report:

- the path written;
- the decision in one sentence;
- the status;
- evidence gaps marked **UNVERIFIED**;
- the index row;
- prior ADRs read or superseded.

Do not write code, edit production files, or open a pull request.

## Stop conditions

Stop after the draft and index update. Ask before marking the ADR accepted, before
superseding an accepted ADR, and before implementation. If the decision is
ambiguous or an accepted ADR blocks it, ask one question and stop.

## Guardrails

- Do not write code or edit production files.
- Do not edit an accepted ADR body. Draft a superseding ADR.
- Do not mark an ADR accepted without explicit approval.
- Do not invent evidence, requirements, or user intent.
- Do not create a second record when an existing proposed ADR is the right home.
- Do not duplicate a guide the repository already has. Read and follow it.
- Do not use dashes as punctuation.
- Do not turn the ADR into a design spec. Use `spec` for that.
