# NixOS config

Declarative replacement for `install.sh` + `stow-all.sh`. Reuses existing
stow dirs (`../i3`, `../polybar`, ...) by symlinking them into home-manager,
so there is one source of truth during migration.

## Layout

```
flake.nix              repo root — entry, sees sibling stow dirs
nix/
├── hosts/
│   ├── common.nix     shared system config (X11, i3, ly, docker, user)
│   ├── vm.nix         throwaway test target
│   └── desktop.nix    real metal — keeps /home on p7
├── home/
│   ├── default.nix    home-manager entry
│   └── modules/       wm / terminal / cli — reuse stow configs
└── (modules/          reusable system modules — planned, not yet present)
```

## Extend

- New machine: add `host = mkHost "host";` in `flake.nix` + `nix/hosts/host.nix`.
- New app: drop a file in `nix/home/modules/` + import it in `home/default.nix`.
- Go native: swap a `*.source = ../../../app/...` block for `programs.app` /
  `services.app`, one app at a time. Rest keeps working.

## Test in VM (no install, throwaway)

```sh
# from repo root. flake files must be git-added (flakes ignore untracked).
git add -A
nix flake lock                  # generate flake.lock — commit it (pins inputs)

# On the ARCH host (no nixos-rebuild there) build the VM via plain nix:
nix build .#nixosConfigurations.vm.config.system.build.vm
./result/bin/run-vm-vm          # qemu window opens; login jan / nix

# (On a NixOS host the shorthand is: nixos-rebuild build-vm --flake .#vm)
```

> **Commit `flake.lock`.** Inputs in `flake.nix` point at *branches*
> (`nixos-25.11`), not revisions. The lock pins each to an exact rev + hash, so
> rebuilds are reproducible and tamper-evident — the supply-chain guarantee that
> the move off AUR is about. Without it every rebuild silently tracks branch tip.

Edit config -> delete `vm.qcow2` -> rebuild -> rerun.

> Caveat: home-manager-as-NixOS-module can misbehave in `build-vm` (store
> overlay bug). If the user config does not apply, validate in a full QEMU
> install instead — that mirrors real metal exactly.

## Deploy to metal (desktop) — DATA-SAFE runbook

> The configs ship PLACEHOLDER disk devices (every build warns). NixOS never
> formats on its own — `nixos-install` only mounts what you prepared under
> `/mnt`. The danger is procedural: format the wrong partition by hand. Follow
> exactly.

1. **Verify partitions first** — never trust `pN` numbering blind:
   ```sh
   lsblk -o NAME,SIZE,FSTYPE,LABEL,PARTLABEL
   blkid /dev/nvme0n1p4   # MUST show TYPE="swap"
   blkid /dev/nvme0n1p7   # MUST show your btrfs /home (do NOT touch)
   blkid /dev/nvme0n1p8   # the existing ESP — holds Windows boot (do NOT mkfs)
   ```
2. **Format ONLY root (p6).** Recreate the `@` subvol; leave p7/p8/p4 ALONE:
   ```sh
   mkfs.btrfs -f /dev/nvme0n1p6
   mount /dev/nvme0n1p6 /mnt && btrfs subvolume create /mnt/@ && umount /mnt
   mount -o subvol=@,compress=zstd:3,noatime /dev/nvme0n1p6 /mnt
   mkdir -p /mnt/home /mnt/efi
   mount -o subvol=@home,compress=zstd:3,noatime /dev/nvme0n1p7 /mnt/home  # EXISTING data
   mount /dev/nvme0n1p8 /mnt/efi   # EXISTING ESP — mount, never mkfs
   swapon /dev/nvme0n1p4
   ```
3. **Generate UUID-based hardware config** (replaces the placeholders):
   ```sh
   nixos-generate-config --root /mnt
   cp /mnt/etc/nixos/hardware-configuration.nix nix/hosts/hardware-configuration.nix
   ```
   Open it: confirm `/home` is the `@home` subvol by-UUID and `/efi` is p8.
   Then in `desktop.nix`: uncomment the import AND delete the placeholder
   `fileSystems."/"`/`/home`/`/efi`/`swapDevices` block (the generated file owns them).
4. `nixos-install --flake .#desktop` → set root + jan passwords.
5. Reboot. `/home/jan` survives intact (uid 1000 + gid 1000 match the old owner).
   Windows still boots (its ESP entry untouched; "Linux Boot Manager" added).

## Known gaps to handle before metal

- `greenclip` — AUR-only, needs an overlay/package.
- `.zshrc` — antigen removed; plugins now sourced from distro packages (Arch pacman / Nix `home.packages`). Reused safely, no runtime fetch.
- Java/Maven helpers `process-helper`, `systemd-manager` — toolchain (`jdk`/`maven`) is already in common.nix; the gap is packaging the two jars as derivations.
- kmonad device-by-id, xrandr monitor names — machine-specific, port as-is.
