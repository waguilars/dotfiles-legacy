# ------------------------------------------------------------------------------
# Codely theme config
# ------------------------------------------------------------------------------
export CODELY_THEME_MINIMAL=false
export CODELY_THEME_MODE="dark"
export CODELY_THEME_PROMPT_IN_NEW_LINE=false
export CODELY_THEME_PWD_MODE="short" # full, short, home_relative

# ------------------------------------------------------------------------------
# Languages
# ------------------------------------------------------------------------------
export GEM_HOME="$HOME/.gem"
export GOPATH="$HOME/.go"
# mise's `activate` emits `unset GOBIN` and its hook-env then points GOBIN at the
# Go install dir, so `go install` placed binaries inside
# ~/.local/share/mise/installs/go/<version>/bin and dropped them on every Go
# upgrade. Opt out of that (must precede `mise activate`, which runs after this
# file) so `go install` uses the default $GOPATH/bin, already on PATH.
export MISE_GO_SET_GOBIN=false
export GOBIN="$GOPATH/bin"
export DENO_INSTALL="$HOME/.deno"
export BUN_INSTALL="$HOME/.bun"
export KAFKA_HOME="/opt/Kafka/current"

# ------------------------------------------------------------------------------
# Custom Exports
# ------------------------------------------------------------------------------
export EDITOR="nvim"
export IDEA_INSTALL_DIR="$HOME/.local/share/JetBrains/Toolbox/apps/intellij-idea"
export AQUA_ROOT_DIR="$HOME/.local/share/aquaproj-aqua"
export AQUA_GLOBAL_CONFIG="$HOME/.dotfiles/aqua.yaml"
export PNPM_HOME="$HOME/.local/share/pnpm"
export STARSHIP_CONFIG="${DOTFILES_PATH}/shell/config/starship.toml"
export FZF_DEFAULT_OPTS="
--no-sort
--reverse
"

# ------------------------------------------------------------------------------
# Apps
# ------------------------------------------------------------------------------
# if [ "$CODELY_THEME_MODE" = "dark" ]; then
#   fzf_colors="pointer:#ebdbb2,bg+:#3c3836,fg:#ebdbb2,fg+:#fbf1c7,hl:#8ec07c,info:#928374,header:#fb4934"
# else
#   fzf_colors="pointer:#db0f35,bg+:#d6d6d6,fg:#808080,fg+:#363636,hl:#8ec07c,info:#928374,header:#fffee3"
# fi

# export FZF_DEFAULT_OPTS="--color=$fzf_colors --reverse"

# ------------------------------------------------------------------------------
# Path - The higher it is, the more priority it has
# ------------------------------------------------------------------------------
export path=(
  "$DOTFILES_PATH/bin/work"
  "$KAFKA_HOME/bin"
  "$IDEA_INSTALL_DIR/bin"
  "$HOME/.opencode/bin"
  "$PNPM_HOME/bin"
  "$HOME/bin"
  "$HOME/.local/bin"
  "$DOTLY_PATH/bin"
  "$DOTFILES_PATH/bin"
  "$JAVA_HOME/bin"
  "$GEM_HOME/bin"
  "$GOPATH/bin"
  "$DENO_INSTALL/bin"
  "$HOME/.cargo/bin"
  "$AQUA_ROOT_DIR/bin"
  "$BUN_INSTALL/bin"
  "/usr/games"
  "/usr/local/opt/ruby/bin"
  "/usr/local/opt/python/libexec/bin"
  "/opt/homebrew/bin"
  "/usr/local/bin"
  "/usr/local/sbin"
  "/bin"
  "/usr/bin"
  "/usr/sbin"
  "/sbin"
)
