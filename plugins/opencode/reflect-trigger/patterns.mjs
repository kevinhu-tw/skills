// Durable workflow phrases that should attach the reflect skill.
export const WORKFLOW_PATTERNS = [
  /\bfrom now on\b/i,
  /\bgoing forward\b/i,
  /\bnext time\b/i,
  /\bremember (this|that)\b/i,
  /\b(don'?t|do not) do (this|that) again\b/i,
  /\bstop doing\b/i,
  /\b(adjust|change|update|fix|improve)\b.{0,40}\b(workflow|skill|routine)\b/i,
  /\b(change|adjust|update)\b.{0,40}\b(how we|the way we|our process)\b/i,
  /\b(make|set) (this|that) the default\b/i,
]

// Phrases that explicitly opt out, including the plugin's own directive.
const OPT_OUT_PATTERNS = [
  /^\s*\/reflect\b/i,
  /\bdo not (load|use|trigger) (the )?reflect\b/i,
  /\bthis is not a workflow change\b/i,
  /\[workflow reflection\]/i,
]

export function matchesWorkflowChange(text) {
  if (typeof text !== "string" || text.trim() === "") {
    return false
  }
  if (OPT_OUT_PATTERNS.some((pattern) => pattern.test(text))) {
    return false
  }
  return WORKFLOW_PATTERNS.some((pattern) => pattern.test(text))
}
