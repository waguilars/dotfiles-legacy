# Source init scripts (skip files prefixed with _)
for file in "$DOTFILES_PATH/shell/init.scripts"/*; do
  [[ -f "$file" ]] || continue
  [[ "$(basename "$file")" == _* ]] && continue
  source "$file"
done
