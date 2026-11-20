---
name: pr-review
description: Review a pull request, branch, commit range, or design document. Explains the architecture and the change first, then reviews architecture, design, implementation, security, tests, and claims versus behavior with severity-ranked findings and path and line evidence. Use when the user says review this PR, review my branch, review this diff, review this design, or asks for a second pass. Read-only by default. Do not use to create or update a PR; use pr-create.
---

# PR Review

Review for correctness and design, not for style. The first job is to explain the
change so the author and the reviewer share a mental model. The second job is to
find the places where that model breaks.

Read-only by default. Do not modify files, post comments, or approve a PR unless
the user asks.

## Input

- No argument: the current branch against its base.
- A PR number or URL: that PR.
- A branch name: that branch against the default base.
- A commit range: that range.
- A path to a markdown file: a design review.
- A focus area: review that area first, but do not skip the other axes.

## Establish the scope

Identify the input:

- A GitHub PR URL or number.
- A local branch and base.
- A commit range.
- A design document, ADR, or proposal.
- A diff with no PR.

For a GitHub PR, collect the metadata and the diff:

```bash
gh pr view <number> --json title,body,baseRefName,headRefName,commits,files,reviews,statusCheckRollup
gh pr diff <number>
```

For a local branch, fetch the base and diff against the merge base:

```bash
git fetch origin <base>
git diff --stat <base>...<head>
git diff --unified=80 <base>...<head>
git log --oneline <base>..<head>
```

Read the PR body, the linked issue or ADR, and the commit messages before the
code. They state the intent and the claims the review must test.

Classify the changed files:

- Production code.
- Tests.
- Configuration and deployment.
- Documentation and examples.
- Generated or vendored code.
- Build and CI.

For a large PR, map the files by subsystem and review one subsystem at a time.
Do not skim the diff and call it a review.

## Explain the change first

Write a short architecture section before any findings. Five to ten lines is
enough. It must answer:

- What problem does the change solve?
- Where does it sit in the system: which package, process, layer, or boundary?
- What is the data flow and control flow through the change?
- What state is created, read, mutated, or deleted?
- What interfaces and dependencies are touched, and which direction do they
  point?
- What invariants must hold for the change to be correct?
- What is the smallest mental model a reviewer needs?

Cite the files and symbols that support the explanation. If you cannot explain
the change, say what is missing instead of guessing.

## Review axes

### Architecture

- Boundaries and layering: does the change respect the existing package, process,
  and ownership boundaries?
- Dependency direction: do new imports point the right way? Any cycle, leaky
  abstraction, or implementation detail escaping through an interface?
- Interface shape: is the interface minimal, stable, and at the right level? Are
  data types aliases or copies? Is the caller forced to know internals?
- State ownership: who owns the state? Is it duplicated, cached, or able to go
  stale? What is the source of truth?
- Extensibility: does the change add a general mechanism or a special case? Is
  the mechanism justified by more than one caller?
- Consistency: does it follow existing patterns or invent a parallel one?
- Duplication: is there already a function, type, or workflow that does this?

### Design

- Invariants: what must always be true, and where is it enforced?
- Lifecycle: create, start, stop, delete, retry, replace, reconcile. Does every
  path leave the system in a valid state?
- Concurrency: races, ordering, locks, context cancellation, timeouts, and
  shared mutable state.
- Idempotency: can the operation run twice safely? What happens after a partial
  failure?
- Failure modes: error propagation, cleanup, rollback, retry policy, and whether
  the caller can recover.
- Operability: logs, metrics, status, debuggability, configuration, and safe
  defaults.
- Compatibility: API, config, state, schema, and migration. Is a breaking change
  intended and documented?
- Reversibility: can the change be rolled back without data loss?

### Implementation

- Correctness: nil and empty values, bounds, overflow, ordering, timeouts,
  resource leaks, and error paths.
- Tests: do they assert the behavior, the failure case, and the boundary? Are
  they deterministic? Do they test the real implementation or a mock of it?
- Naming and comments: do they match behavior? Are there stale comments or
  comments that describe an older design?
- Dead code, debug code, generated code, and commented-out code.
- Error messages: actionable, specific, and free of secrets.
- Performance: unnecessary allocations, N+1 calls, blocking work, or unbounded
  growth.

### Security

- Input validation and trust boundaries. Which inputs are attacker controlled?
- Command injection, path traversal, SSRF, template injection, and unsafe
  deserialization.
- Authentication, authorization, tenancy, and privilege.
- Secrets in argv, environment, logs, files, error messages, and process lists.
- File permissions, temporary files, symlinks, and cleanup.
- Supply chain: new dependencies, install scripts, pinned versions, and
  provenance.
- Unsafe defaults: open ports, permissive CORS, disabled TLS verification,
  wildcard permissions.
- Denial of service: unbounded input, retries, timeouts, and resource limits.

### Claims versus behavior

- The PR body, comments, docs, commit messages, and tests must match the code.
- A test that asserts less than its name claims is a finding.
- A comment that describes an older behavior is a finding.
- An error message that promises a recovery the code does not implement is a
  finding.
- A migration or compatibility claim needs evidence, not a sentence.

## Findings

Report findings by severity, highest first. Each finding needs a location, the
defect, the consequence, and a concrete fix.

```text
[high] path/to/file.go:123: <what is wrong>.
Consequence: <what breaks, for whom, and when>.
Fix: <the smallest concrete change that removes the defect>.
```

Severity:

- High: security issue, data loss, crash, deadlock, leak, incorrect result, or a
  broken primary flow.
- Medium: design flaw, missing failure handling, test gap that could hide a
  defect, operational risk, or a compatibility problem.
- Low: maintainability, clarity, duplication, naming, or a missing comment that
  would prevent a future defect.
- Nit: style or preference. Never block on a nit.

Label each finding as a defect or a preference. If you are unsure, say so
explicitly. Do not present a preference as a correctness issue.

Separate observations from findings. An observation is context, not a request
for a change.

## Output

Use this order:

1. Scope: what was reviewed, the base and head, and what was not reviewed.
2. Architecture: the short explanation from above.
3. Findings: by severity, highest first, with path and line.
4. Claims versus behavior: the PR body and comments that do not match the code.
5. Top three fixes: the smallest set that most improves correctness or safety.
6. Questions: what the author must answer before a verdict is possible.
7. Verdict: block, fix first, approve with nits, approve, or needs author input.

The verdict must follow the findings:

- Block when there is a high finding.
- Fix first when there are medium findings.
- Approve with nits when only low and nit findings remain.
- Approve when there are no findings.
- Needs author input when a question blocks judgment.

Do not approve a PR with failing checks or unverified claims.

## Design review mode

When the input is an ADR, proposal, or design spec, review the document instead
of a diff. Check:

- The problem is stated in observable terms.
- Goals and non-goals are explicit.
- Constraints are real: compatibility, performance, security, operations, cost,
  team, and deadline.
- At least two options were considered, with trade-offs and a reason for the
  chosen one.
- Each material decision has a consequence and a rollback.
- Interfaces, data flow, state, errors, concurrency, and failure modes are
  specified.
- Security and operability are covered.
- Migration, compatibility, and rollout are covered.
- The test plan covers the happy path, a failure case, a boundary, and the
  migration.
- The implementation plan is commit sized and ordered.
- Every requirement is testable. Every open question has an owner and a default.

Use section references instead of line numbers when the document is likely to
change. End with the same verdict and top three fixes.

## If asked to fix

- Fix the smallest self-contained set of findings.
- One commit per logical fix unless the user asks otherwise.
- Do not mix in refactors, formatting, or unrelated cleanup.
- Re-run the tests that cover each fix.
- Re-review the new diff, including the interaction between fixes.
- Update the PR body if the behavior or testing changed.
- Do not resolve review threads, request changes, or approve on the user's behalf
  unless the user asks.

If posting the review to GitHub, use the same format and write the body to a
temporary file:

```bash
gh pr review <number> --comment --body-file <review-file>
```

Use `--request-changes` or `--approve` only when the verdict supports it and the
user asked for it.

## Guardrails

- Read-only by default.
- Cite path and line for every code finding.
- Distinguish defects from preferences, and say when you are unsure.
- Do not report style nits as correctness issues.
- Do not approve with failing checks, unresolved high findings, or unverified
  claims.
- Do not review secrets, credentials, or customer data out loud. Redact them.
- Do not use dashes as punctuation.
- If the diff is too large to review responsibly, say what you covered and what
  you did not. Do not pretend coverage.
