# NixOS config

Declarative replacement for `install.sh` + `stow-all.sh`, on **NixOS 26.05**.
Reuses the existing stow dirs (`../i3`, `../polybar`, `../zsh`, …) by symlinking
them into home-manager, so there is one source of truth during migration.

## Hosts (entry points)

`nixos-rebuild switch --flake .#<host>` (on NixOS) or `nixos-install --flake .#<host>`:

| Host | Machine | Notes |
|---|---|---|
| `desktop` | Ryzen 7800X3D + RTX 4090 | NVIDIA, gaming, keeps existing `/home` on p7 |
| `laptop` | Intel iGPU laptop | portable + gaming, keeps its `/home` |
| `surface` | Surface Go (4GB/64GB) | **lean** test box, clean wipe — install rehearsal |
| `vm` | throwaway QEMU | `nix build` smoke test, no install |

## Composition model — traits, not copies

Each host imports `common.nix` + the profiles whose traits it has. Nothing is
duplicated between hosts.

```
flake.nix                  repo root — entry (must be here to see ../stow dirs)
nix/
├── hosts/
│   ├── common.nix         shared base: i3/ly, audio, network, fonts, user, security
│   ├── desktop.nix        + workstation + NVIDIA 4090 + AMD/SSD hw + disks
│   ├── laptop.nix         + workstation + portable + Intel/laptop hw + disks
│   ├── surface.nix        + portable + surface-go hw + my.lean=true (NO workstation)
│   └── vm.nix             minimal, build-vm bootloader
├── profiles/
│   ├── workstation.nix    gaming (steam/proton), docker, bluetooth/print/scan,
│   │                      ssh/tailscale, system-check timer  → desktop + laptop
│   └── portable.nix       Intel iGPU + power-profiles + zram  → laptop + surface
├── modules/
│   └── lean.nix           defines the `my.lean` flag
└── home/
    ├── default.nix        home-manager entry (shared by all hosts)
    └── modules/
        ├── wm.nix         i3/polybar/rofi/dunst/picom + gestures (symlink stow dirs)
        ├── terminal.nix   .zshrc/.newsboat + pinned zsh plugins
        └── packages.nix   base + heavy tiers; heavy dropped when my.lean
```

**Lean split:** `packages.nix` lists every app once in a `base` or `heavy` tier.
Heavy (toolchains, big GUI, emulators, gaming) is dropped on lean hosts via
`lib.optionals (!osConfig.my.lean) heavy`. desktop ≈ 156 pkgs, surface ≈ 109.

## Extend

- **New machine:** `host = mkHost "host";` in `flake.nix` + `nix/hosts/host.nix`
  composing the profiles it needs.
- **New trait shared by several hosts:** add a `nix/profiles/*.nix`, import it
  where wanted (don't copy settings between host files).
- **New app:** add it to `base` or `heavy` in `packages.nix`.
- **Go native:** swap a `*.source = ../../../app/...` symlink for `programs.app`
  / `services.app`, one app at a time.

## Test in VM (no install)

```sh
git add -A                 # flakes ignore untracked files
nix flake lock             # (re)generate flake.lock — COMMIT it (pins inputs)
nix build .#nixosConfigurations.vm.config.system.build.vm   # Arch host: no nixos-rebuild
./result/bin/run-vm-vm     # qemu window; login jan / nix
```
Edit config → delete `vm.qcow2` → rebuild → rerun. Validate fast with
`nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath`
(checks every option/package name without building).

> Caveat: home-manager-as-NixOS-module can misbehave in `build-vm`. If the user
> config doesn't apply, validate in a full QEMU/metal install instead.

## Rehearse the install on the Surface Go (recommended first)

A clean-wipe install on the throwaway Surface proves the whole flow before any
machine that matters. Use the **26.05 x86_64** minimal ISO (NOT aarch64):
`https://channels.nixos.org/nixos-26.05/latest-nixos-minimal-x86_64-linux.iso`.

1. Disable Secure Boot (hold Vol-Up + Power → Security). Boot USB-C drive
   (Vol-Down + Power). Surface Go has only USB-C — bring an adapter.
2. `nmtui` for wifi (or USB-C ethernet).
3. Partition the eMMC (clean wipe, nothing to keep):
   ```sh
   parted /dev/mmcblk0 -- mklabel gpt
   parted /dev/mmcblk0 -- mkpart ESP fat32 1MB 512MB
   parted /dev/mmcblk0 -- set 1 esp on
   parted /dev/mmcblk0 -- mkpart root ext4 512MB 100%
   mkfs.fat -F32 -n BOOT /dev/mmcblk0p1
   mkfs.ext4 -L nixos /dev/mmcblk0p2
   mount /dev/disk/by-label/nixos /mnt
   mkdir /mnt/boot && mount /dev/disk/by-label/BOOT /mnt/boot
   ```
4. Get the flake (push dotfiles to GitHub, then `--flake github:sch-28/<repo>#surface`),
   `nixos-generate-config --root /mnt`, copy its hardware file in + uncomment the
   import, then `nixos-install --flake …#surface`. Reboot.

## Deploy to metal (desktop) — DATA-SAFE runbook

> NixOS never formats on its own — `nixos-install` only mounts what you prepared
> under `/mnt`. The configs ship PLACEHOLDER disks (every build warns). The only
> real risk is procedural: formatting the wrong partition by hand. Back up first.

1. **Verify partitions — never trust `pN` numbering blind:**
   ```sh
   lsblk -o NAME,SIZE,FSTYPE,LABEL,PARTLABEL
   blkid /dev/nvme0n1p4   # MUST show TYPE="swap"
   blkid /dev/nvme0n1p7   # MUST show your btrfs /home (do NOT touch)
   blkid /dev/nvme0n1p8   # existing ESP — holds Windows boot (do NOT mkfs)
   ```
2. **Format ONLY root (p6).** Leave p7/p8/p4 ALONE:
   ```sh
   mkfs.btrfs -f /dev/nvme0n1p6
   mount /dev/nvme0n1p6 /mnt && btrfs subvolume create /mnt/@ && umount /mnt
   mount -o subvol=@,compress=zstd:3,noatime /dev/nvme0n1p6 /mnt
   mkdir -p /mnt/home /mnt/efi
   mount -o subvol=@home,compress=zstd:3,noatime /dev/nvme0n1p7 /mnt/home  # EXISTING data
   mount /dev/nvme0n1p8 /mnt/efi   # EXISTING ESP — mount, never mkfs
   swapon /dev/nvme0n1p4
   ```
3. **Generate UUID-based hardware config** (replaces placeholders):
   ```sh
   nixos-generate-config --root /mnt
   cp /mnt/etc/nixos/hardware-configuration.nix nix/hosts/hardware-configuration.nix
   ```
   Confirm `/home` = `@home` subvol by-UUID, `/efi` = p8. In `desktop.nix`:
   uncomment the import AND delete the placeholder `fileSystems`/`swapDevices` block.
4. `nixos-install --flake .#desktop` → set root + jan passwords.
5. Reboot. `/home/jan` survives (uid 1000 + gid 1000 match). Windows still boots
   ("Linux Boot Manager" added alongside; its ESP entry untouched).

## Known gaps (deliberately skipped — see CLAUDE/AGENTS notes)

- `greenclip`, `kmonad` — not wired (user deprioritised).
- Java/Maven helpers `process-helper`/`systemd-manager` — toolchain present in
  `packages.nix` (heavy tier); packaging the two jars as derivations is the gap.
- `bitwarden-desktop` runs EOL electron-39.8.10 (upstream-pinned) — whitelisted
  in `common.nix`; revisit when upstream bumps electron.
- Machine-specific i3 bits (xrandr `DP-*`, kmonad device-by-id) — port as-is.
