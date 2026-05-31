# Load tool hooks once per session (eval init, completions, etc.)

[[ -n "${ZSH_VERSION:-}" ]] || return 0
[[ -z ${_DOTFILES_HOOKS_INIT-} ]] || return 0
_DOTFILES_HOOKS_INIT=1

_command_exists() {
  (( ${+commands[$1]} ))
}

source "${DOTFILES_PATH}/shell/hooks/hooks.zsh"
