# Check if running over WSL
if [ -n "$WSL_DISTRO_NAME" ]; then
    ln -s /mnt/c/Windows/SysWOW64/clip.exe $HOME/.local/bin/clip 
fi