mkdir -p $HOME/.local/bin

# Restore common
sudo apt-get install xclip wget gpg apt-transport-https unzip

# Respore alias 
cargo install bat exa

# Restore zsh apps
curl -sS https://starship.rs/install.sh | sh -s -- --yes # Starship prompt

# Node management
curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell  && #fnm for node version management
ln -s $HOME/.local/share/fnm/fnm $HOME/.local/bin/fnm &&
fnm install --lts &&
npm install -g tldr
