# Enable aliases to be sudo’ed
alias sudo='sudo '

# Replace base for better commands
alias ls='eza -g --icons'
alias ll='eza -lgh --icons --git'
alias la='eza -lgah --icons --git'
alias tree='eza --tree --icons'
alias cat='bat'

if [ -n "${ZSH_VERSION:-}" ]; then
  whence compdef >/dev/null 2>&1 && compdef eza=ls
fi

# alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='df -h'

alias vim='nvim'

alias ..="cd .."
alias ...="cd ../.."
alias dotfiles='cd $DOTFILES_PATH'

# Git
alias gs='git status -sb'
alias lzg='lazygit'

# Docker
alias lzd='lazydocker'

# Utils
alias k='kill -9'
alias i.='(idea $PWD &>/dev/null &)'
alias c.='(code $PWD &>/dev/null &)'
alias o.='open .'
# alias up='dot package update_all'
