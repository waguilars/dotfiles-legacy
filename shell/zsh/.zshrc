#!/usr/bin/env zsh
# Uncomment for debuf with `zprof`
# zmodload zsh/zprof

source "$DOTFILES_PATH/shell/zsh/zim.zsh"

# ZSH Ops
setopt HIST_FCNTL_LOCK
setopt +o nomatch

source "$DOTFILES_PATH/shell/init.sh"
source "$DOTFILES_PATH/shell/hooks/_init.sh"

source "$DOTLY_PATH/shell/zsh/bindings/dot.zsh"
source "$DOTFILES_PATH/shell/zsh/key-bindings.zsh"
source "$DOTFILES_PATH/shell/zsh/plugins/sudo.zsh"

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'
# personal config for secrets
[[ -r "$HOME/.config/secrets/secrets.env" ]] && source "$HOME/.config/secrets/secrets.env"
# linuxbew config
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
