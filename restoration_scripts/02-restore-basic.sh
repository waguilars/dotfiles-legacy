# Restore common
sudo apt-get install xclip wget gpg apt-transport-https

# Respore alias 
cargo install bat exa

# Restore zsh apps
curl -sS https://starship.rs/install.sh | sh # Starship prompt

curl -fsSL https://fnm.vercel.app/install | bash #fnm for node version management

# Code MS Repo
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
