#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
COMMANDS_SRC="$REPO_DIR/commands"

usage() {
  cat <<'EOF'
Install the skills in this repository for OpenCode, Claude Code, Cursor, and Codex.

Usage:
  ./install.sh [options]

Options:
  --target <all|opencode|claude|cursor|codex>  Agent to install for (default: all)
  --scope <user|project>                       User or project install (default: user)
  --copy                                       Copy files instead of symlinking
  --dest <dir>                                 Base directory for the install
                                               (default: $HOME for user, $PWD for project)
  --force                                      Replace an existing destination
  --dry-run                                    Print actions without changing anything
  -h, --help                                   Show this help

Layout:
  user:    ~/.config/opencode/skills, ~/.config/opencode/commands,
           ~/.claude/skills, ~/.claude/commands,
           ~/.agents/skills
  project: .opencode/skills, .opencode/commands,
           .claude/skills, .claude/commands,
           .agents/skills

Cursor and Codex share .agents/skills. The command is installed for OpenCode and
Claude Code; Cursor and Codex invoke the skill directly.
EOF
}

target=all
scope=user
mode=symlink
dest=
force=0
dry_run=0

while [ $# -gt 0 ]; do
  case "$1" in
    --target)
      target="${2:?--target needs a value}"
      shift 2
      ;;
    --scope)
      scope="${2:?--scope needs a value}"
      shift 2
      ;;
    --copy)
      mode=copy
      shift
      ;;
    --dest)
      dest="${2:?--dest needs a value}"
      shift 2
      ;;
    --force)
      force=1
      shift
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$target" in
  all|opencode|claude|cursor|codex) ;;
  *)
    echo "unknown target: $target" >&2
    exit 2
    ;;
esac

case "$scope" in
  user|project) ;;
  *)
    echo "unknown scope: $scope" >&2
    exit 2
    ;;
esac

if [ -n "$dest" ]; then
  base="$dest"
elif [ "$scope" = project ]; then
  base="$PWD"
else
  base="$HOME"
fi

if [ "$scope" = project ]; then
  opencode_root="$base/.opencode"
else
  opencode_root="$base/.config/opencode"
fi
claude_root="$base/.claude"
agents_root="$base/.agents"

say() {
  printf '%s\n' "$*"
}

run() {
  if [ "$dry_run" -eq 1 ]; then
    say "would: $*"
  else
    "$@"
  fi
}

install_one() {
  local src="$1"
  local dst="$2"
  src="${src%/}"

  if [ "$mode" = symlink ] && [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    say "ok: $dst"
    return
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ "$force" -ne 1 ]; then
      if [ "$dry_run" -eq 1 ]; then
        say "conflict: $dst (use --force)"
        return
      fi
      echo "refusing to replace $dst (use --force)" >&2
      exit 1
    fi
    say "remove: $dst"
    run rm -rf "$dst"
  fi

  say "install: $dst"
  run mkdir -p "$(dirname "$dst")"
  if [ "$mode" = copy ]; then
    run cp -R "$src" "$dst"
  else
    run ln -s "$src" "$dst"
  fi
}

install_skills() {
  local root="$1"
  local src
  for src in "$SKILLS_SRC"/*/; do
    if [ ! -f "${src}SKILL.md" ]; then
      continue
    fi
    install_one "$src" "$root/$(basename "$src")"
  done
}

install_commands() {
  local root="$1"
  local src
  for src in "$COMMANDS_SRC"/*.md; do
    if [ ! -e "$src" ]; then
      continue
    fi
    install_one "$src" "$root/$(basename "$src")"
  done
}

install_for_opencode() {
  install_skills "$opencode_root/skills"
  install_commands "$opencode_root/commands"
}

install_for_claude() {
  install_skills "$claude_root/skills"
  install_commands "$claude_root/commands"
}

install_for_agents() {
  install_skills "$agents_root/skills"
}

case "$target" in
  opencode)
    install_for_opencode
    ;;
  claude)
    install_for_claude
    ;;
  cursor|codex)
    install_for_agents
    ;;
  all)
    install_for_opencode
    install_for_claude
    install_for_agents
    ;;
esac

if [ "$scope" = user ] && [ -d "$base/.config/opencode/skill" ]; then
  say "note: OpenCode also reads $base/.config/opencode/skill; remove any duplicate skill there."
fi

if [ "$dry_run" -eq 0 ]; then
  skill_names=()
  for src in "$SKILLS_SRC"/*/; do
    if [ -f "${src}SKILL.md" ]; then
      skill_names+=("$(basename "$src")")
    fi
  done
  command_names=()
  for src in "$COMMANDS_SRC"/*.md; do
    if [ -e "$src" ]; then
      command_names+=("$(basename "$src" .md)")
    fi
  done

  say ""
  say "Installed for $target ($scope scope)."
  case "$target" in
    opencode|all)
      say "OpenCode: /<command>, for example /pr-create or /quiz"
      ;;
  esac
  case "$target" in
    claude|all)
      say "Claude Code: /<command> or /<skill>"
      ;;
  esac
  case "$target" in
    cursor|all)
      say "Cursor: / then select a skill"
      ;;
  esac
  case "$target" in
    codex|all)
      say "Codex: /skills then select a skill, or \$<skill>"
      ;;
  esac
  say "Skills: ${skill_names[*]}"
  say "Commands: ${command_names[*]}"
fi
