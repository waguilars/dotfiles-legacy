#!/usr/bin/env bash
set -euo pipefail

# Remove skills listed in a registry JSON from configured agent skill directories.
#
# Usage:
#   gentle-ai-clean-skills [--dry-run] [--registry PATH] [--agent NAME]...
#
# Defaults:
#   registry: $DOTFILES_PATH/gentle-ai/registry/removed-skills.json
#   agents:   all agents listed in the registry (or state.json when present)

DOTFILES_PATH="${DOTFILES_PATH:-$HOME/.dotfiles}"
DEFAULT_REGISTRY="$DOTFILES_PATH/gentle-ai/registry/removed-skills.json"
REGISTRY="${GENTLE_AI_REMOVED_SKILLS_REGISTRY:-$DEFAULT_REGISTRY}"
DRY_RUN=false
SELECTED_AGENTS=()

usage() {
  cat <<EOF
Usage: gentle-ai-clean-skills [options]

Remove skills listed in the registry from opencode, cursor, and pi skill dirs.

Options:
  --dry-run           Print actions without deleting anything
  --registry PATH     Registry JSON (default: $DEFAULT_REGISTRY)
  --agent NAME        Limit to one or more agents (opencode, cursor, pi)
  -h, --help          Show this help

Environment:
  GENTLE_AI_REMOVED_SKILLS_REGISTRY  Override default registry path
  DOTFILES_PATH                      Dotfiles root (default: ~/.dotfiles)
EOF
}

log_info() { echo "[info] $*"; }
log_ok() { echo "[ok] $*"; }
log_warn() { echo "[warn] $*" >&2; }
log_err() { echo "[error] $*" >&2; }

expand_path() {
  local path="$1"
  path="${path/#\~/$HOME}"
  printf '%s' "$path"
}

json_get() {
  local expr="$1"
  local file="$2"
  if command -v jq >/dev/null 2>&1; then
    jq -r "$expr" "$file"
    return
  fi
  python3 - "$expr" "$file" <<'PY'
import json, sys

expr, path = sys.argv[1], sys.argv[2]
with open(path, encoding="utf-8") as fh:
    data = json.load(fh)

if expr == ".skills[]":
    for item in data.get("skills", []):
        print(item)
elif expr == ".agents | keys[]":
    for key in data.get("agents", {}):
        print(key)
elif expr.startswith(".agents[\"") and expr.endswith("\"].skills_dirs[]"):
    agent = expr.split('"')[1]
    for item in data.get("agents", {}).get(agent, {}).get("skills_dirs", []):
        print(item)
else:
    raise SystemExit(f"unsupported expression without jq: {expr}")
PY
}

agent_enabled() {
  local agent="$1"
  if ((${#SELECTED_AGENTS[@]} > 0)); then
    local selected
    for selected in "${SELECTED_AGENTS[@]}"; do
      if [[ "$selected" == "$agent" ]]; then
        return 0
      fi
    done
    return 1
  fi

  local state_file="$HOME/.gentle-ai/state.json"
  if [[ -f "$state_file" ]] && command -v jq >/dev/null 2>&1; then
    jq -e --arg agent "$agent" '.installed_agents[]? | select(. == $agent)' "$state_file" >/dev/null 2>&1
    return $?
  fi

  return 0
}

remove_skill_path() {
  local target="$1"
  if [[ -L "$target" ]]; then
    if $DRY_RUN; then
      log_info "would remove symlink: $target"
    else
      rm "$target"
      log_ok "removed symlink: $target"
    fi
    return 0
  fi

  if [[ -d "$target" ]]; then
    if $DRY_RUN; then
      log_info "would remove directory: $target"
    else
      rm -rf "$target"
      log_ok "removed directory: $target"
    fi
    return 0
  fi

  if [[ -e "$target" ]]; then
    if $DRY_RUN; then
      log_info "would remove file: $target"
    else
      rm "$target"
      log_ok "removed file: $target"
    fi
    return 0
  fi

  return 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --registry)
      [[ $# -ge 2 ]] || { log_err "--registry requires a path"; exit 1; }
      REGISTRY="$2"
      shift 2
      ;;
    --agent)
      [[ $# -ge 2 ]] || { log_err "--agent requires a name"; exit 1; }
      SELECTED_AGENTS+=("$2")
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      log_err "unknown option: $1"
      usage >&2
      exit 1
      ;;
  esac
done

[[ -f "$REGISTRY" ]] || { log_err "registry not found: $REGISTRY"; exit 1; }

mapfile -t SKILLS < <(json_get '.skills[]' "$REGISTRY")
if ((${#SKILLS[@]} == 0)); then
  log_warn "registry contains no skills: $REGISTRY"
  exit 0
fi

mapfile -t AGENTS < <(json_get '.agents | keys[]' "$REGISTRY")
if ((${#AGENTS[@]} == 0)); then
  log_err "registry contains no agents: $REGISTRY"
  exit 1
fi

removed=0
missing=0
skipped_agents=0

log_info "registry: $REGISTRY"
log_info "skills: ${SKILLS[*]}"
if $DRY_RUN; then
  log_warn "dry-run mode enabled; nothing will be deleted"
fi

for agent in "${AGENTS[@]}"; do
  if ! agent_enabled "$agent"; then
    log_info "skip agent (not selected/installed): $agent"
    skipped_agents=$((skipped_agents + 1))
    continue
  fi

  mapfile -t SKILL_DIRS < <(json_get ".agents[\"$agent\"].skills_dirs[]" "$REGISTRY")
  if ((${#SKILL_DIRS[@]} == 0)); then
    log_warn "agent $agent has no skills_dirs in registry"
    continue
  fi

  for raw_dir in "${SKILL_DIRS[@]}"; do
    skills_dir="$(expand_path "$raw_dir")"
    if [[ ! -d "$skills_dir" ]]; then
      log_warn "skills dir missing for $agent: $skills_dir"
      continue
    fi

    for skill in "${SKILLS[@]}"; do
      target="$skills_dir/$skill"
      if remove_skill_path "$target"; then
        removed=$((removed + 1))
      else
        missing=$((missing + 1))
      fi
    done
  done
done

log_ok "done: removed=$removed missing=$missing skipped_agents=$skipped_agents"
