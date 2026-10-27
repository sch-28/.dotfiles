# Stow config packages

Config dirs are GNU stow packages mirroring `$HOME`. E.g.
`i3/.config/i3/config` -> `~/.config/i3/config`. `stow-all.sh` stows only its
explicit `packages` / `no_fold` lists — add new packages there. Root files: `ly/`
is stowed to `/` with sudo; `system-check/`, `gpu/` and `snap-pac/` mirror `/` and are
copied by `install.sh`. `install.sh` is the imperative Arch bootstrap
(pacman/yay/nvm/bob/antigen).

## Key areas

- `i3/.config/i3/` — i3 config + helper scripts (autotiling, quick-launch, voice-memo).
- `polybar/`, `rofi/`, `dunst/`, `picom/` — WM stack; scripts call playerctl/nvidia-smi/xrandr.
- `zsh/.zshrc` — antigen plugins; hardcoded nvm/bob/Android paths.
- `zsh/.zprofile` — login-shell env; ly execs the session through a login shell, so
  this reaches i3 and everything rofi spawns. Holds the Qt/KDE vars dolphin needs;
  `i3/.config/i3/config` forwards them to the D-Bus activation env as well.
- `kde/.config/kdeglobals` — Breeze Dark colors + terminal for all Qt/KDE apps.
  KDE writes through the stow symlink, so app UI state lands back in the repo.
- `nvim/` — neovim (lua), managed via bob.
- `kmonad/`, `systemd/` — key remap + user units; hardware-specific device paths.
- `hypr/` — Hyprland Lua config + scripts; `dms/` — Dux Shell settings. Dux and its plugin
  manager rewrite `settings.json`/`plugin_settings.json` through the stow links, so app state
  churns in git like kdeglobals. Status/decisions: `hyprland-plan.md`.

## Quirks

- Configs hold machine-specific values (xrandr `DP-*` outputs, kmonad device-by-id). Don't generalize.
- Stow uses real symlinks — edits to `~/.config/x` edit the repo file directly.

## Conventions

Read `team://knowledge/general-practices` before changing scripts here.
