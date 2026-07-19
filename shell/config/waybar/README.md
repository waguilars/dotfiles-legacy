# Waybar for KDE Plasma

This configuration is managed by Dotbot and links to `~/.config/waybar`.

## Requirements

- A KDE Plasma Wayland session
- `waybar`
- A Nerd Font that provides the displayed icons, such as Symbols Nerd Font Mono

## Start from Plasma

This repository does not create a Plasma autostart entry, so it does not alter the native Plasma panel. To start Waybar automatically, open **System Settings > Startup and Shutdown > Autostart**, add a login script with the command `waybar`, and keep the native panel unchanged or hide it through Plasma's own panel settings.

For a one-time launch from a Plasma Wayland terminal, run:

```sh
waybar
```
