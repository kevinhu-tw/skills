import assert from "node:assert/strict"

import { matchesWorkflowChange } from "../plugins/opencode/reflect-trigger/patterns.mjs"

const shouldMatch = [
  "From now on, always run lint before tests.",
  "Going forward, keep PR bodies short.",
  "Next time, use a worktree.",
  "Remember this: no dashes as punctuation.",
  "Don't do that again.",
  "Stop doing a full rebuild for a docs change.",
  "I think we should adjust our workflow this way.",
  "Going forward, cite path:line in review findings.",
  "Make this the default for PR bodies.",
  "Let's change how we review PRs.",
  "Let's change our process for releases.",
]

const shouldNotMatch = [
  "",
  "Run the tests and show me the output.",
  "What does this function do?",
  "Reflect on the parser code.",
  "Do not load reflect for this message.",
  "This is not a workflow change.",
  "We should use a map here.",
  "Update the process function to return an error.",
]

for (const text of shouldMatch) {
  assert.equal(matchesWorkflowChange(text), true, `should match: ${text}`)
}

for (const text of shouldNotMatch) {
  assert.equal(matchesWorkflowChange(text), false, `should not match: ${text}`)
}

console.log("ok")
