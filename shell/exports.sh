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
# export JAVA_HOME='/usr/lib/jvm/adoptopenjdk-11-hotspot-amd64' # managed by sdkman
export GEM_HOME="$HOME/.gem"
export GOPATH="$HOME/.go"
export DENO_INSTALL="$HOME/.deno"

# ------------------------------------------------------------------------------
# Custom Exports
# ------------------------------------------------------------------------------

export NVM_LAZY_LOAD=true
export NVM_COMPLETION=true
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
  "$HOME/bin"
  "$HOME/.local/bin"
  "$DOTLY_PATH/bin"
  "$DOTFILES_PATH/bin"
  "$JAVA_HOME/bin"
  "$GEM_HOME/bin"
  "$GOPATH/bin"
  "$DENO_INSTALL/bin"
  "$HOME/.cargo/bin"
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
