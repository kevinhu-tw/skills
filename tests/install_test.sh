#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

"$REPO_DIR/install.sh" --target all --dest "$tmp/all" >/dev/null
"$REPO_DIR/install.sh" --target all --dest "$tmp/all" >/dev/null

[ -L "$tmp/all/.config/opencode/skills/repo-quiz" ] || fail "opencode skill is not a symlink"
[ -f "$tmp/all/.config/opencode/skills/repo-quiz/SKILL.md" ] || fail "opencode skill content"
[ -f "$tmp/all/.config/opencode/commands/quiz.md" ] || fail "opencode command"
[ -L "$tmp/all/.claude/skills/repo-quiz" ] || fail "claude skill is not a symlink"
[ -f "$tmp/all/.claude/skills/repo-quiz/SKILL.md" ] || fail "claude skill content"
[ -f "$tmp/all/.claude/commands/quiz.md" ] || fail "claude command"
[ -L "$tmp/all/.agents/skills/repo-quiz" ] || fail "agents skill is not a symlink"
[ -f "$tmp/all/.agents/skills/repo-quiz/SKILL.md" ] || fail "agents skill content"

mkdir -p "$tmp/project"
(
  cd "$tmp/project"
  "$REPO_DIR/install.sh" --target codex --scope project --copy >/dev/null
)
[ -d "$tmp/project/.agents/skills/repo-quiz" ] || fail "codex project skill dir"
[ ! -L "$tmp/project/.agents/skills/repo-quiz" ] || fail "copy mode should not symlink"
[ -f "$tmp/project/.agents/skills/repo-quiz/SKILL.md" ] || fail "codex skill content"

mkdir -p "$tmp/conflict/.agents/skills"
touch "$tmp/conflict/.agents/skills/repo-quiz"
if "$REPO_DIR/install.sh" --target codex --dest "$tmp/conflict" >/dev/null 2>&1; then
  fail "conflict should fail without --force"
fi
"$REPO_DIR/install.sh" --target codex --dest "$tmp/conflict" --force >/dev/null
[ -L "$tmp/conflict/.agents/skills/repo-quiz" ] || fail "--force should replace the conflict"

echo "ok"
