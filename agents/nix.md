# NixOS port

Declarative replacement for `install.sh` + `stow-all.sh`. `flake.nix` at repo
root (must be there to reference sibling stow dirs). All config under `nix/`.

## Structure (see nix/README.md for the full picture)

- `flake.nix` — entry; `mkHost` builds each host. Inputs pinned to nixpkgs/home-manager **26.05**.
- 4 hosts: `desktop` (4090, nvidia+workstation), `laptop` (intel+workstation+portable), `surface` (lean test box, portable, `my.lean`), `vm` (throwaway).
- `nix/hosts/common.nix` — shared base (X11/i3/ly, pipewire, network, fonts, user jan uid 1000 gid 1000).
- `nix/profiles/` — composable traits: `workstation.nix` (gaming/docker/peripherals/system-check → desktop+laptop), `portable.nix` (intel iGPU/power/zram → laptop+surface).
- `nix/modules/lean.nix` — `my.lean` flag; gates the heavy app tier in packages.nix.
- `nix/home/modules/{wm,terminal,packages}.nix` — REUSE stow dirs via `.source = ../../../<app>/...`; packages split base/heavy.

## Quirks

- Flakes copy only git-tracked files — `git add -A` before any build/eval.
- home-manager wired as NixOS module; `osConfig` available in home modules (used for `my.lean`).
- Validate with `nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath` (no build).
- Reuse-via-symlink first; migrate to native `programs.*`/`services.*` per-app later.
- `.zshrc` is antigen-free + portable (works Arch + Nix); zsh plugins via exact store paths.

## Conventions

Read `team://knowledge/general-practices` before changing Nix files.
