# Stow config packages

Each top-level dir is a GNU stow package mirroring `$HOME`. E.g.
`i3/.config/i3/config` -> `~/.config/i3/config`. `stow-all.sh` stows all except
`ly` (stowed to `/` with sudo). `install.sh` is the imperative Arch bootstrap
(pacman/yay/nvm/bob/antigen).

## Key areas

- `i3/.config/i3/` — i3 config + helper scripts (autotiling, quick-launch, voice-memo).
- `polybar/`, `rofi/`, `dunst/`, `picom/` — WM stack; scripts call playerctl/nvidia-smi/xrandr.
- `zsh/.zshrc` — antigen plugins; hardcoded nvm/bob/Android paths.
- `nvim/` — neovim (lua), managed via bob.
- `kmonad/`, `systemd/` — key remap + user units; hardware-specific device paths.

## Quirks

- Configs hold machine-specific values (xrandr `DP-*` outputs, kmonad device-by-id). Don't generalize.
- Stow uses real symlinks — edits to `~/.config/x` edit the repo file directly.

## Conventions

Read `team://knowledge/general-practices` before changing scripts here.
