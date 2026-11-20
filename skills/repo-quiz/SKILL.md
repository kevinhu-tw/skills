---
name: repo-quiz
description: Quiz the user on a codebase or a named topic inside it, testing architecture, implementation details, invariants, failure modes, configuration, and design rationale with evidence-backed questions, adaptive follow-ups, and an honest debrief. Use whenever the user says quiz me, grill me, test my understanding, ask me questions about this repo or codebase, interview me on this code, mock interview me, viva me, check what I know about a module, or wants to practice explaining how a system works. Do not use when the user wants an explanation, review, or documentation; this skill asks the questions and the user answers.
---

# Repo Quiz

Run an adaptive oral exam over a codebase. The user answers; you grade against
the code. The goal is to find the edge of their understanding, not to produce a
summary or a lecture.

The quiz works because retrieval is harder and more informative than
recognition. Ask for explanations, predictions, and diagnoses, not names. Ground
every question in code so the answer key is defensible and the debrief points to
something real.

## Session contract

Settle only what you cannot infer, state it in one line, then ask the first
question:

- Scope: the current working directory by default. A git repo is not required.
  Accept another path, a named topic, or a diff or PR.
- Depth: quick is 5 questions, working is 8 (default), deep is 12. For a narrow
  topic, use the lower end.
- Book: open by default. Answer from memory first, then check the repo to
  confirm specifics. Closed book means no lookup.
- Format: free recall by default. Multiple choice only when asked.

If the user says "quiz me" with no scope, use the current directory. If it does
not contain code, ask for a path. If a named topic is not in the repo, say so
and offer the closest matches. Do not turn the start into a questionnaire.

Example opening:

```text
Quiz: <repo>, working depth, 8 questions, open book. Answer from memory first;
say hint, skip, harder, easier, or stop.

Q1 [architecture] ...
```

## Map before asking

Read enough to ask grounded questions, then stop:

1. Repo instructions (`CLAUDE.md`, `AGENTS.md`), README, docs index, decision
   records, and the active plan or milestone.
2. Entry points: CLI commands, server routes, `main`, public interfaces.
3. Package boundaries and dependency direction.
4. For each candidate area, one representative implementation, its call sites,
   and its tests. Tests encode behavior and edge cases.
5. For a topic, start at its tests and interfaces, then read the implementation,
   call sites, config, and docs.
6. For a diff or PR, read the changed files, their call sites, and the tests
   that cover them.

Write down 8 to 12 candidate claims with evidence. A claim is a specific
behavior, invariant, default, or design decision. Drop anything you cannot
support with a file and line, a symbol, or a command output. Code is truth.
Docs are evidence of intent and a good source of doc-drift questions. If an
explore subagent is available, use it for breadth, but verify every key claim
yourself before asking.

Keep the mapping proportional to the quiz. A five-question quick quiz does not
need a full architecture review. Do not read the whole repo to ask eight
questions. If the repo is too large to map in a reasonable pass, propose a
module boundary in one line and proceed; do not stall on coverage.

## Answer key before question

For each candidate, write the key before you ask:

```text
id:
area: architecture | flow | invariant | failure | config | rationale | nuance
level: recall | trace | diagnose | design
question:
expected:
evidence: path:line (symbol) or command + output
common wrong:
follow-up:
```

`expected` is a strong answer in two to four sentences, not a list of keywords.
Keep the key out of the chat until the user answers. Writing it first prevents
leading questions and post-hoc grading. If the expected answer is not defensible
from the evidence, drop the candidate. If line numbers may have shifted, cite
the symbol and file; do not guess.

## Coverage

A working quiz covers at least four of these areas. In repo mode, span at least
two packages or modules. In topic mode, stay inside the topic and use
neighboring code only as context. Do not spend more than two questions on one
area unless the user asks to go deep there.

| Area | What to probe |
| --- | --- |
| architecture | boundaries, ownership, dependency direction |
| flow | entry point to side effect, ordering |
| invariant | preconditions, idempotency, cleanup, ownership |
| failure | missing input, partial failure, retries, rollback |
| config | precedence, defaults, fallbacks |
| rationale | decision records, rejected alternatives, constraints |
| nuance | concurrency, caching, compatibility, doc drift |

### Question stems

| Area | Stems |
| --- | --- |
| architecture | "Which component owns X? What breaks if it stops doing that?" |
| flow | "Walk X from the entry point to the side effect. Where is Y decided?" |
| invariant | "What must be true before this runs? Where is it enforced?" |
| failure | "A user sees Y. What are the first two hypotheses, and what do you check?" |
| config | "Which value wins when A and B are both set? What is the default?" |
| rationale | "What constraint does this design satisfy? What did it trade away?" |
| nuance | "If you removed this check, what symptom appears first? Why is it there?" |

## Question ladder

Use four levels, and move up or down based on the answer. Start at working
level: a trace or diagnose question a regular contributor should handle, not a
trivia warm-up.

| Level | What it tests | Shape |
| --- | --- | --- |
| recall | a default, owner, or contract | "Which component owns X, and what is the default?" |
| trace | a path from input to side effect | "Walk through X from the command to the state write." |
| diagnose | a failure and the first check | "The user sees Y. What are the first two hypotheses?" |
| design | a trade-off or blast radius | "If you removed this check, what breaks first?" |

One concept per question. Ask for mechanism and consequence, not function names.
No yes/no questions, no leading questions, no multi-part questions. Scenario
questions are strongest: "A user runs X and sees Y. What do you check first, and
why?"

Avoid trivia, questions whose answer is a sentence copied from the README,
generated or vendored code unless it is the topic, and anything that touches
secrets. If the user probably has not read the area, orient them in one line or
pick another area. Do not quiz blind on an obscure detail.

## Pacing

One follow-up per question is the limit. If the follow-up is still partial or
missed, explain in two to four sentences and move on; stacking follow-ups turns
the quiz into an interrogation.

Two weak answers in a row: drop a level or switch to another area. Rebuild with a
question the user can answer. After a miss, queue a variant two to three
questions later, not immediately.

End on a question the user can answer. Use a design capstone only when the run
has been solid; otherwise close with a working-level trace and put the design
question in the debrief as a reading task.

## Ask and grade

Ask one question at a time and wait. Do not answer for the user. If a question
tool is available and the user asked for multiple choice, use it; otherwise list
options A to D in the message.

After the answer, grade it:

- Full: the mechanism, condition, and consequence the question asks for are
  right.
- Partial: the area is right, but a condition or consequence is missing.
- Miss: the mechanism or owner is wrong, or the user does not know.

Cite the evidence in one line. Accept equivalent wording; grade the mechanism,
not the vocabulary. If the answer is correct but the file path is wrong, say so
without downgrading the answer. If the user challenges the key, re-read the
code. If they are right, correct the key and say so. Never defend a wrong key.
If their answer exposes a real bug or doc drift, note it; do not grade it wrong.

For a partial answer, ask one narrowing follow-up before moving on, without
revealing the missing piece. For a miss, explain in two to four sentences, then
queue a variant two to three questions later. For a correct answer, raise the
level. Hints escalate from area to concept to answer, and a hinted answer is
marked as such. Do not give participation trophies.

If the user says skip or pass, mark it skipped. If they ask for the reasoning,
give the answer and the evidence, then continue with the next question. If they
say they are not sure, explain instead of guessing what they meant. If they say
stop, go to the debrief. If they ask for a status check, give one line, not the
full debrief. If they ask why a question is being asked, name the concept without
giving the answer. If they ask "is it X", do not confirm; ask them to commit
first.

## Worked exchange

This is the shape to aim for: one question, one answer, one grade, one line of
evidence, then the next question.

```text
Q3 [invariant] Two creates race for the same name. What stops them from
interleaving, and what does the loser see?

A: The state store locks the cluster directory, so the second create gets
ErrBusy.

Partial. The lock is right. It is a per-cluster flock, not a state-wide lock, so
different names proceed. Evidence: pkg/state/lock.go:36 (Lock).

Q4 [failure] ...
```

Do not append a second follow-up when the correction above is enough. The next
question is the better use of the turn.

## Debrief

Use this shape:

```text
## Debrief

| Area | Verdict | Note |
| --- | --- | --- |
| flow | shaky | prepare vs bringUp |
| failure | solid | stageCreate vs stageConverge |
| ... | ... | ... |

Top three corrections:
1. ... Evidence: path:line (symbol)
2. ...
3. ...

Reading tasks:
1. path: symbol, symbol
2. ...
3. ...

Next round: another area, harder, closed book, or multiple choice.
```

For solid areas, point to the next layer; for gaps, point to the missing
foundation. No single percentage unless the user asks for one.

## State

Keep a ledger in the session temp directory, never in the repo. If the
environment gives no temp path, use `mktemp -d`:

```text
contract, concept map, candidate bank, asked questions, answers, grades,
follow-ups due, misconceptions, verdicts by area
```

Re-read it before a question after a long gap or compaction. Delete it on
request. Do not create quiz files in the repo.

## Guardrails

- Read-only. Never edit the repo, run migrations, or change cluster state.
  Read-only commands and tests are fine and are good evidence.
- Never read `.env` files or secrets.
- Never invent a file, line, behavior, or design rationale. Verify or omit.
- Do not turn the quiz into a lecture. Explanations stay short; the point is the
  user's retrieval.
- Do not invent intent. Ask what the code does, or what a documented decision
  says, not what the author privately meant.
- Match the user's language and formatting.
- Stop when the user says stop, or at the agreed count.

## Output shape

Opening:

```text
Quiz: <repo>, working depth, 8 questions, open book. Answer from memory first;
say hint, skip, harder, easier, or stop.

Q1 [architecture] ...
```

After an answer:

```text
Correct. ...
Evidence: path/to/file.go:42 (symbol)
```

Then the next question. Keep the question and the grade compact; the debrief is
where the detail belongs.
