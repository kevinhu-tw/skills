---
name: reflect
description: Reflect on a completed task, session, or recent work to improve the skill library. Finds repeated corrections, missing steps, ambiguous instructions, wrong triggers, stale references, and output mismatches, then proposes or applies the smallest patch to an existing skill or a new skill only when the loop is distinct and recurring. Use when the user says reflect, retrospective, what should we update in the skills, from now on, going forward, next time, remember this, always, never, adjust our workflow, change our workflow, update the skill, or states a durable preference about how work should be done. Do not use for a code review or a project postmortem.
---

# Reflect

Turn corrections into durable skill changes. The unit of improvement is the
smallest patch that would have prevented the correction, not a rewrite.

The skill is a reflection routine. It can run at the end of a task, after a
session, or on demand against a named skill. An explicit workflow change is
applied; an exploratory one is proposed and left for approval.

## Input

- No argument: the current session.
- A skill name: reflect on that skill.
- A task or time window: reflect on that scope.
- A transcript or file: read it first.

## Locate the library

The skill library is the repository that contains this skill's `SKILL.md`. If the
installed skill is a symlink, resolve it to the real path. Do not assume the
current working directory is the library. The library may be a different
repository from the code you are working on.

Read the library's README and tests before editing. The relevant paths are
usually `skills/<name>/SKILL.md`, `commands/<name>.md`, and
`tests/install_test.sh`. If the change touches automatic triggering, also read
`plugins/opencode/reflect-trigger/` and `tests/reflect_trigger_test.mjs`.

## When to run

Run the reflection after the user's current request, not before it. If the
request also contains a task, finish the task first. If the workflow change
affects the current task, apply it before continuing.

Do not reflect on every message. Reflect when the user states a durable
preference, corrects the process, or asks for a retrospective. A one-off task
detail is not a reflection trigger.

## Evidence

Use the conversation you are in. If the user gives a transcript, a task, a time
window, or a skill name, use that instead.

Look for:

- Direct corrections: "don't do this", "next time", "remember this", "too long",
  "not what I asked", "where is the evidence", "you skipped".
- Repeated requests: the user asks for the same output shape twice, or reformats
  the agent's output.
- Rework: the user rewrites a PR body, a review finding, a spec section, or a
  command.
- Failed gates: the agent claimed a test passed without running it, or skipped a
  check.
- Missed triggers: the user invokes a skill by name because it did not fire.
- Stale references: a path, command, flag, or convention in a skill no longer
  exists.
- Contradictions: two skills give different instructions for the same situation.
- Friction: the agent asked for information it could have found, or took a step
  the user did not want.

Quote the smallest piece of evidence that shows the friction. A feeling is not
evidence.

## Classify the friction

Choose one:

- Missing step: the skill did not say to do something.
- Ambiguous instruction: the skill said it, but the agent interpreted it
  differently.
- Wrong order: the step existed but happened too late.
- Output mismatch: the format, length, or audience was wrong.
- Trigger problem: the skill did not fire, or fired when it should not.
- Stale fact: the skill references something that changed.
- Duplication: two skills say the same thing differently.
- Unnecessary step: the skill asks for work the user does not want.
- One-off: not a skill issue. Do not encode it.

A one-off bug, a project-specific fact, or a single ambiguous comment is not a
skill change. An explicit "remember this" or "next time" is enough to justify a
patch. When the signal is weak, ask before editing.

## Decide where it belongs

- Project-specific fact or command: the repository's `AGENTS.md`, README, or a
  local skill. Not the global skill library.
- Stable user preference: the relevant skill's output contract or style rules.
- Missing process step: the relevant skill's procedure.
- New recurring loop: a new skill, only if it has a distinct trigger, a stable
  input, an output contract, and a stop condition.
- Two skills overlapping: merge or cross-reference, do not duplicate.
- Wording fix: edit the existing skill. Do not create a new file.

Prefer editing an existing skill over creating a new one. Prefer a specific
instruction over a principle. Prefer a checklist item over a paragraph. Prefer an
example over an abstract rule.

## Explicit and exploratory changes

An explicit change states that the workflow should change from now on. Examples:
"from now on", "going forward", "next time", "always", "never", "remember this",
"make this the default", "update the skill". Treat it as approval to apply the
smallest patch.

An exploratory change is a question or a proposal. Examples: "maybe we should",
"what do you think about", "could we", "I think we should" without a durable
marker. Propose the patch and ask one question. Do not edit until the user
confirms.

If the intent is mixed, treat it as exploratory. If the change would affect more
than one skill, propose the split before editing.

## Propose the patch

Show the exact change. Do not say "improve the skill".

```text
Skill: <name>
Finding: <what went wrong>
Evidence: <quote or artifact>
Change:
  old: <exact text, or "new section">
  new: <exact text>
Why: <the correction this prevents>
Risk: <what could regress, or "none">
```

Keep the patch small. If the change is larger than one section, split it into
multiple patches and recommend the first.

If the right change is a new skill, include:

- Name and one-line purpose.
- Trigger phrases.
- Inputs and scope.
- Procedure.
- Output contract.
- Stop conditions.
- What it must not do.

## Apply

For an explicit change:

1. Identify the skill and the exact section.
2. Apply the smallest patch, not a full rewrite.
3. Update the README if the skill list, invocation, or install layout changed.
4. Run `tests/install_test.sh` in the skills repository.
5. Run the trigger test if the change touches the reflect trigger.
6. Verify the skill is registered if the agent exposes a skill list.
7. Commit with a one-line, problem-focused message.
8. Report the diff, the tests, and the commit.

For an exploratory change, stop after the proposal and wait for approval.

Do not rename a skill or command without checking every reference. Do not change
a trigger description without checking that the old phrase still routes somewhere
sensible.

If the change is to a user's notes or vault, ask before writing. Do not automate
the user's notes.

## Reflection ledger

Keep a short ledger in the chat:

| Skill | Finding | Evidence | Patch | Status |
| --- | --- | --- | --- | --- |
| pr-create | Body still too long | "reduce the length" | Add a length rule | proposed |
| pr-review | Findings lacked line numbers | "where is this" | Require path and line | applied |

Do not write the ledger to the repository unless the user asks. The chat is
enough for the session.

## Library review

When the user asks to reflect on the library as a whole, also check:

- Duplicate instructions across skills.
- Inconsistent names for the same concept.
- Commands that do not match skill names.
- README drift from the actual layout.
- Installer gaps or broken symlinks.
- Trigger collisions between skills.
- Skills that are too long to load or too vague to act on.
- Skills that never fire, or fire for the wrong task.

Report the smallest set of changes that improves the library. Do not propose a
rewrite because the library is uneven.

## Routine

At the end of a task, ask:

1. Did the user correct anything that a skill should prevent?
2. Did the agent skip a gate, claim an unverified result, or reformat the output?
3. Did the skill fire when it should, and did it fire when it should not?
4. Is the issue one-off or recurring?
5. What is the smallest patch that would have prevented it?

If the answer is nothing, say "no skill change" and stop. Do not invent work to
justify the reflection.

## Guardrails

- Do not encode a one-off.
- Do not encode project-specific facts in a global skill.
- Do not create a new skill for a loop that happened once.
- Do not rewrite a whole skill when a sentence will do.
- Do not update a skill from a single ambiguous comment without asking.
- Do not treat an exploratory proposal as approval.
- Do not reflect before finishing the current task unless the change affects it.
- Do not edit from a project working directory. Resolve the library path first.
- Do not conflict with an existing skill. Check the related skills first.
- Do not automate the user's notes or vault.
- Do not use dashes as punctuation.
