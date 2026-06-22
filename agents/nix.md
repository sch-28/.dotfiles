# NixOS port

Declarative replacement for `install.sh` + `stow-all.sh`. `flake.nix` at repo
root (must be there to reference sibling stow dirs). All config under `nix/`.

## Structure

- `flake.nix` — entry; `mkHost` builds each host. Inputs pinned to nixpkgs/home-manager 25.11.
- `nix/hosts/common.nix` — shared system (X11, i3, ly, pipewire, docker, user jan uid 1000).
- `nix/hosts/{vm,desktop}.nix` — vm = throwaway test target; desktop = metal, keeps `/home` on p7.
- `nix/home/` — home-manager; `modules/{wm,terminal,cli}.nix` REUSE existing stow dirs via `.source = ../../../<app>/...`.

## Quirks

- Flakes copy only git-tracked files — `git add -A` before any `nixos-rebuild`.
- home-manager wired as NixOS module (one `nixos-rebuild switch` does all).
- Reuse-via-symlink first; migrate to native `programs.*`/`services.*` per-app later.
- `.zshrc` symlinked as-is breaks under Nix (antigen/nvm/bob) — clean before metal.

## Conventions

Read `team://knowledge/general-practices` before changing Nix files.
