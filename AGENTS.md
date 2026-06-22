# dotfiles

Personal Linux config repo. GNU **stow** packages — each top-level dir
(`i3/`, `polybar/`, `zsh/`, ...) mirrors `$HOME` and is symlinked into place by
`stow-all.sh`. Primary stack: Arch + X11 + i3. A parallel **NixOS** port lives
under `nix/` (declarative replacement for `install.sh` + stow).

## Principles

- **Ask, don't assume**: scope or design unclear? Ask before coding. One question beats a wrong implementation.
- **Read before touching**: read every file relevant to the task before changing anything.
- **Do the minimum**: only change what was asked. No side refactors, no "while I'm here" improvements.
- **DRY**: check if something already exists before writing it.
- **No backwards-compat cruft**: delete unused code completely. Update all call sites.
- **Security at boundaries**: validate input, never trust client-supplied roles/IDs, never log secrets.

## Working in this project

- Stow config packages (i3, polybar, rofi, dunst, kitty, tmux, zsh, ...) — read `agents/dotfiles.md`.
- NixOS port under `nix/` + `flake.nix` — read `agents/nix.md`.
- Maintenance / Java-Maven / harden scripts under `scripts/` — read `agents/scripts.md`.
