---
name: pr-create
description: Prepare a branch for review and open or update a pull request. Runs the project's lint, build, and tests, gathers exact testing evidence, self-reviews the final diff, and writes the PR body in the user's format with a separate internal report. Use when the user says create a PR, open a PR, update the PR description, finish this branch, ship this, or asks for a PR summary. Do not use to review someone else's PR; use pr-review.
---

# PR Creation

Take a branch from "works on my machine" to a reviewable pull request. The PR is
not a changelog. It is a compact argument that the change is correct, tested, and
safe to merge.

The skill has two outputs with different audiences:

1. The PR body, written for reviewers. It contains only what a reviewer needs.
2. The internal report, written to the user in chat. It contains worktree state,
   design decisions, conflicts, and anything else that should not be in the PR.

Never mix them.

## Input

- No argument: use the current branch and infer the base from the repository or
  an existing PR.
- A PR number or URL: update that PR.
- A branch name: create or update the PR for that branch.
- A draft request: create the PR as a draft and say which gates are still open.

## Before you start

Read the repository's instructions first: `AGENTS.md`, `CLAUDE.md`,
`CONTRIBUTING.md`, the README, the Makefile or task runner, and the CI workflows.
They define the commands and conventions this skill must follow.

Establish the change:

- Current branch, base branch, and whether the branch is stacked on another
  feature branch.
- The diff against the merge base, not just the last commit.
- The linked issue, ADR, proposal, or prior PR.
- The commit list and whether the messages are one line and problem focused.
- The worktree state. Uncommitted changes stay out of the PR and go in the
  internal report.
- Any generated files, vendored code, secrets, or large binaries in the diff.

Check whether the base has moved:

```bash
git fetch origin <base>
git log --oneline HEAD..origin/<base>
```

If the branch is not rebased on the current base, decide whether a rebase is
needed before validation. If you rebase, create a backup branch first, then use
`--force-with-lease`.

## Validate with the project's commands

Find the canonical commands before running anything. Look at the CI workflows,
Makefile, task runner, `package.json`, `go.mod`, `pyproject.toml`, and
`CONTRIBUTING.md`. Do not invent a command when the project already has one.

Run the gates in this order, stopping at the first failure:

1. Formatting or generated-code check.
2. Lint and static analysis.
3. Build or compile.
4. Unit tests.
5. Integration tests.
6. End-to-end tests, only when the change or the project requires them.

For each gate, record:

- The exact command.
- The environment, including OS, architecture, runtime, and services.
- The exit status.
- The key output, not the entire log.
- What the gate covered and what it did not.

If a gate fails, fix the cause and run it again. Do not open a ready PR with a
known failure. If the user explicitly wants a draft PR to exercise CI, mark it
draft and say which gates are still red.

For end-to-end tests, use a clean environment when the project expects one.
Never reset or delete a shared environment without asking. If the clean-state
procedure is not documented, say so and ask for it.

## Gather testing evidence

Evidence is a command and an observed result, not a claim. Use lists, not a long
paragraph.

- Unit tests: the command, the package or suite, and the pass or fail result.
- Lint: the command and the result, including the issue count when the tool
  reports one.
- Build: the command and the artifact or binary produced.
- Manual checks: the environment, the steps, and what you saw.
- End-to-end: the environment, the command, the duration, and what it covered.
- Not run: the check that was not run and the reason. Never leave this implicit.

If CI is the only evidence, wait for the check to finish before claiming it
passed. A queued or running check is not a pass.

## Self-review the final diff

Review your own diff before writing the PR body. This is a defect pass, not a
style pass. If a `pr-review` skill is available, run it on the final diff after
this checklist.

- The diff contains only files that belong to this change.
- No secrets, tokens, credentials, private keys, or environment files.
- No debug prints, commented-out code, temporary files, or generated artifacts
  that should not be committed.
- No unrelated refactors, formatting churn, or dependency upgrades.
- Tests cover the new behavior and at least one failure or boundary case.
- Docs, examples, configuration, CLI help, and migration notes are updated when
  the change affects them.
- Error messages are actionable and do not leak sensitive values.
- The PR body matches the diff. Remove any claim that the code does not support.
- The base branch is correct, especially for a stacked PR.
- The commit messages are one line and describe the problem, not the file.
- The validation commands in the PR body are the commands that actually ran.

If the self-review finds a defect, fix it before opening the PR. Do not hide it
in the body as a known issue unless the user explicitly accepts it.

## Write the PR body

Use this format unless the repository has a stricter template. Keep each
paragraph on one physical line. Do not insert manual line breaks inside a
paragraph. Use lists when there is more than one point.

```markdown
## Summary

<One to three sentences. What the branch does and why it matters.>

## What changed

- <Area>: <change>.
- <Area>: <change>.

## Why

<One short paragraph. The problem, the constraint, and the alternative that was
rejected if that helps a reviewer.>

## Implications

- *<Title>*: <one sentence. Add context only if it changes what a reviewer or
  operator must do.>

## Reviewer focus

- *<Title>*: <what to scrutinize and why. Omit this section when there is no
  specific ask.>

## Testing

Environment: <OS, architecture, runtime, services, data>.

- <Check>: `<command>` <result and key output>.
- <Manual check>: <what you did and what you saw>.
- Not run: <what was not run and why>.

## Gotchas

- <Known limitation, risk, or follow-up. Omit when there is none.>
```

Rules for the body:

- Summary is one to three sentences, not a background essay.
- What changed is three to seven bullets, grouped by area, not by file.
- Why explains the problem, not the implementation.
- Implications use the exact form `*Title*: one sentence.` They describe what
  changes for a reviewer, operator, or user.
- Reviewer focus is optional. Use it when there is a real decision or risky
  area, not to repeat the summary.
- Testing is a list of commands and observed results. Include the environment.
- Gotchas are real limitations or follow-ups, not a second testing section.
- Do not include uncommitted worktree state, design arguments, branch conflicts,
  or internal notes. Those go in the internal report.
- Do not use dashes as punctuation.
- Do not claim a check passed before it ran.

The PR title should identify the change, not the branch. Use the issue key when
the repository uses one, then a short imperative or noun phrase. A title like
"Update code" is not acceptable.

## Push the branch

`gh pr create` needs the branch on the remote. Push it before opening the PR.

For a new branch:

```bash
git push -u origin <branch>
```

After a rebase or any history rewrite, use a lease and a backup:

```bash
git branch backup/<branch>-<date>
git push --force-with-lease origin <branch>
```

Never use plain `--force`. If the push is rejected because the remote moved,
fetch and inspect the new commits before deciding whether to rebase again.

## Open or update the PR

Write the body to a file in the session temp directory, never in the repository.
Use the file with `gh` to avoid shell quoting problems.

Create a PR:

```bash
gh pr create --base <base> --head <branch> --title "<title>" --body-file <body-file>
```

Create it as a draft when the branch is still exercising CI or the user asks for
a draft:

```bash
gh pr create --draft --base <base> --head <branch> --title "<title>" --body-file <body-file>
```

Update an existing PR:

```bash
gh pr edit <number> --body-file <body-file>
```

If the branch is stacked on another feature branch, set the base to that branch,
not the default branch, and state the stack in the body. Retarget with
`gh pr edit <number> --base <base>` when the lower PR merges.

After opening or updating:

- Watch the checks that matter, not just the first green icon.
- If a check fails, investigate and fix it. Do not update the body to say it
  passed.
- When CI finishes, update the Testing section with the actual result.
- Mark the draft ready only when the gates the project requires have passed.
- If the repository requires labels, reviewers, or a project board, follow its
  convention. Do not add reviewers or labels that the user did not ask for.

## Internal report to the user

After the PR exists, send a separate report in chat. This is not the PR body.

```markdown
## Summary

<What the branch does and which features it adds.>

## Layout

<The design and the high-level code changes, with the main files and packages.>

## Testing

<Automated and manual checks, with the exact commands and results.>

## Notes

<Uncommitted worktree state, design decisions, conflicts, deferred items, and
anything the user needs to know but a reviewer does not.>
```

State clearly what is implemented and what is deferred. Do not claim a check that
did not run. Do not paste the internal report into the PR.

## Failure handling

- Lint or unit failure: fix it, rerun the gate, and update the evidence.
- CI failure: read the failing job, reproduce locally when possible, fix, push,
  and watch again.
- Rebase conflict: create a backup branch, rebase, resolve by keeping both
  intents, rerun the gates, then `--force-with-lease`.
- Existing PR: update it instead of opening a duplicate.
- Wrong base: retarget the PR before asking for review.
- Body claim without code: remove the claim or add the missing code and test.

## Guardrails

- Do not commit secrets or generated files that the repository does not track.
- Do not squash, rewrite, or force push without a backup and without the user's
  consent.
- Do not open a ready PR with a known failing gate.
- Do not write the PR body file into the repository.
- Do not use dashes as punctuation.
- Do not claim a test, benchmark, or CI result that you did not observe.
- Keep the reviewer-facing body clean. Internal context goes to the user.
