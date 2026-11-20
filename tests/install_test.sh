#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

skills=()
for dir in "$REPO_DIR"/skills/*/; do
  if [ -f "${dir}SKILL.md" ]; then
    skills+=("$(basename "$dir")")
  fi
done
[ "${#skills[@]}" -gt 0 ] || fail "no skills found"

commands=()
for file in "$REPO_DIR"/commands/*.md; do
  if [ -e "$file" ]; then
    commands+=("$(basename "$file")")
  fi
done
[ "${#commands[@]}" -gt 0 ] || fail "no commands found"

for name in "${skills[@]}"; do
  file="$REPO_DIR/skills/$name/SKILL.md"
  declared="$(sed -n 's/^name:[[:space:]]*//p' "$file" | head -1)"
  [ "$declared" = "$name" ] || fail "skill $name declares name '$declared'"
  grep -q '^description:' "$file" || fail "skill $name has no description"
  if grep -q '—\|–' "$file"; then
    fail "skill $name contains a dash used as punctuation"
  fi
done

for name in "${commands[@]}"; do
  file="$REPO_DIR/commands/$name"
  grep -q '^description:' "$file" || fail "command $name has no description"
  skill_ref="$(sed -n 's/.*Use the `\([a-z0-9-]*\)` skill.*/\1/p' "$file" | head -1)"
  [ -n "$skill_ref" ] || fail "command $name does not reference a skill"
  [ -f "$REPO_DIR/skills/$skill_ref/SKILL.md" ] || fail "command $name references missing skill $skill_ref"
  if grep -q '—\|–' "$file"; then
    fail "command $name contains a dash used as punctuation"
  fi
done

"$REPO_DIR/install.sh" --target all --dest "$tmp/all" >/dev/null
"$REPO_DIR/install.sh" --target all --dest "$tmp/all" >/dev/null

for name in "${skills[@]}"; do
  [ -L "$tmp/all/.config/opencode/skills/$name" ] || fail "opencode skill $name is not a symlink"
  [ -f "$tmp/all/.config/opencode/skills/$name/SKILL.md" ] || fail "opencode skill $name content"
  [ -L "$tmp/all/.claude/skills/$name" ] || fail "claude skill $name is not a symlink"
  [ -f "$tmp/all/.claude/skills/$name/SKILL.md" ] || fail "claude skill $name content"
  [ -L "$tmp/all/.agents/skills/$name" ] || fail "agents skill $name is not a symlink"
  [ -f "$tmp/all/.agents/skills/$name/SKILL.md" ] || fail "agents skill $name content"
done

for name in "${commands[@]}"; do
  [ -f "$tmp/all/.config/opencode/commands/$name" ] || fail "opencode command $name"
  [ -f "$tmp/all/.claude/commands/$name" ] || fail "claude command $name"
done

mkdir -p "$tmp/project"
(
  cd "$tmp/project"
  "$REPO_DIR/install.sh" --target codex --scope project --copy >/dev/null
)
for name in "${skills[@]}"; do
  [ -d "$tmp/project/.agents/skills/$name" ] || fail "codex project skill dir $name"
  [ ! -L "$tmp/project/.agents/skills/$name" ] || fail "copy mode should not symlink $name"
  [ -f "$tmp/project/.agents/skills/$name/SKILL.md" ] || fail "codex skill content $name"
done

conflict_skill="${skills[0]}"
mkdir -p "$tmp/conflict/.agents/skills"
touch "$tmp/conflict/.agents/skills/$conflict_skill"
if "$REPO_DIR/install.sh" --target codex --dest "$tmp/conflict" >/dev/null 2>&1; then
  fail "conflict should fail without --force"
fi
"$REPO_DIR/install.sh" --target codex --dest "$tmp/conflict" --force >/dev/null
[ -L "$tmp/conflict/.agents/skills/$conflict_skill" ] || fail "--force should replace the conflict"

echo "ok"
