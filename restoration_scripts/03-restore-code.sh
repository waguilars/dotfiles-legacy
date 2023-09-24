

windows_code_path="/mnt/c/Users/$USER/AppData/Local/Programs/Microsoft VS Code/bin/code"

# Code MS Repo (only if not using WSL)
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
    echo "WSL Detected, linking windows code to linux"

    # check if code binary exists
    if [ ! -f "$windows_code_path" ]; then
        echo "Code binary not found in the default Windows installation dir, skipping code installation..."
        exit 0
    fi

    ln -s "$windows_code_path" $HOME/.local/bin
    
else
    echo "Installing code"
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    sudo apt-get install apt-transport-https
    sudo apt-get update
    sudo apt-get install code # or code-insiders
fi


