# Dotfiles

A modular dotfiles repository managed with GNU Stow.

## Overview

This repository contains shell, editor, terminal, and desktop configuration files organized as `stow` packages.

The structure is designed to support both shared configuration and host-specific overrides.

## Requirements

- `git`
- `stow`

Some configurations may also depend on additional system packages, fonts, plugins, or themes.

## Repository Layout

Each top-level directory is a `stow` package.

Examples:

- `common-zsh`
- `common-nvim`
- `common-kitty`
- `common-tmux`
- `laptop-waybar`
- `laptop-hypr`

Each package mirrors its target path inside `$HOME`.

Example:

```text
common-nvim/
  .config/nvim/...
```

When stowed, this is linked to:

```text
~/.config/nvim/...
```

## Installation

### Base requirements

The following tools are required to manage and deploy this repository:

- `git`
- `stow`

### Package-specific requirements

Some packages depend on additional tools, fonts, or plugins.

#### `common-zsh`

- `zsh`
- `oh-my-zsh`
- `zsh-autosuggestions`
- `zsh-syntax-highlighting`
- `lsd` for the `ls` alias
- `fastfetch` for the shell startup command

#### `common-kitty`

- `kitty`
- `JetBrainsMono Nerd Font`

#### `common-nvim`

- `nvim`
- `git` for `lazy.nvim` bootstrap
- `ripgrep` for Telescope project search (`live_grep`)

Optional integrations enabled automatically when available:

- `npm` for `prettier`, `shfmt`, `pyright`, `bashls`, and TypeScript LSP support
- `gem` for `rubocop` and `solargraph`

#### `common-tmux`

- `tmux`

#### `laptop-waybar`

- `waybar`
- `pavucontrol` for the PulseAudio click action
- `upower` for battery tooltip data
- `powerprofilesctl` for power profile detection
- executable permission on `~/.config/waybar/battery-status.sh`
- `Roboto` is currently configured as the Waybar font

#### `laptop-hypr`

- `hyprland`
- `hypridle`
- `hyprlock`
- `kitty`
- `dolphin`
- `hyprlauncher`
- `waybar`
- `brightnessctl`
- `playerctl`
- `wpctl` for audio keybindings
- `hyprctl`

Some keybindings also try to use `hyprshutdown` when available, but fall back gracefully if it is not installed.

Wallpaper collection for `waypaper` and `awww`:

```bash
git clone https://github.com/JaKooLit/Wallpaper-Bank.git ~/Pictures/wallpapers
```

This Hyprland setup expects wallpapers under `~/Pictures/wallpapers`.

### Deploy

Clone the repository:

```bash
git clone <repo-url> ~/git/dotfiles
cd ~/git/dotfiles
```

Stow the packages you want:

```bash
stow -t ~ common-zsh common-nvim common-kitty common-tmux
stow -t ~ laptop-waybar laptop-hypr
```

Some packages include helper scripts that must remain executable after stowing.
For example, the Waybar battery module depends on:

```bash
~/.config/waybar/battery-status.sh
```

If needed, restore the executable bit with:

```bash
chmod +x ~/.config/waybar/battery-status.sh
```

### Post-install checks

After stowing, verify that the expected targets were linked correctly:

```bash
readlink -f ~/.zshrc
readlink -f ~/.config/nvim/init.lua
readlink -f ~/.config/kitty/kitty.conf
readlink -f ~/.config/tmux/tmux.conf
readlink -f ~/.config/waybar/config.jsonc
readlink -f ~/.config/hypr/hyprland.conf
```

## Usage

Stow a package:

```bash
stow -t ~ <package>
```

Remove a package:

```bash
stow -D -t ~ <package>
```

Restow a package:

```bash
stow -R -t ~ <package>
```

When running `stow` from a repository stored outside `$HOME`, explicitly set the target with `-t ~`.
Otherwise, `stow` will use the parent directory of the repository as the default target.

## Host-Specific Packages

Shared packages use the `common-*` naming convention.

Host-specific packages can use names such as:

- `laptop-*`
- `desktop-*`

Avoid having multiple packages manage the same exact target file at the same time.

## Setup Notes

### Fonts

- `Roboto` is currently used by Waybar.
- JetBrains fonts may be required for terminal rendering.
- A Nerd Font may be required for icon glyphs used by tools such as Waybar, depending on the configured icons and font stack.

### Shell

Some shell behavior depends on external packages or plugins.

Examples:

- `lsd`
- `zsh-autosuggestions`
- `zsh-syntax-highlighting`

Optional host-specific tools may also be used depending on the environment.

## Experimental

### Icons

Icon theme setup is currently experimental or legacy.

Previous setups used:

- Arc
- Papirus

This part of the repository may require additional cleanup or restructuring before it is enabled by default.
