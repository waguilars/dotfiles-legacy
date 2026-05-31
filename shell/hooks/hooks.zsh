_command_exists mise && eval "$(mise activate zsh)"
_command_exists starship && eval "$(starship init zsh)"
_command_exists zoxide && eval "$(zoxide init zsh)"
_command_exists atuin && eval "$(atuin init zsh)"

_command_exists bun && [[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
