# Enable aliases to be sudo’ed
alias sudo='sudo '

# Replace bsae for better commands
alias ls='eza --icons'
alias ll='eza -lh --icons --git'
alias la='eza -lah --icons --git'
alias tree='eza --tree --icons'
compdef eza=ls
alias cat='bat'

alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='df -h'

alias vim='nvim'

alias ..="cd .."
alias ...="cd ../.."
alias dotfiles='cd $DOTFILES_PATH'

# Git

# Utils
alias k='kill -9'
alias i.='(idea $PWD &>/dev/null &)'
alias c.='(code $PWD &>/dev/null &)'
alias o.='open .'
# alias up='dot package update_all'
