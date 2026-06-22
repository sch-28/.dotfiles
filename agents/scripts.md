# scripts/

Maintenance + hardening + two small Java/Maven helper services.

## Key areas

- `update.sh` — pacman/yay update + cache/orphan cleanup.
- `check.sh` — system health (btrfs/NVMe SMART); run by system-check systemd timer.
- `harden/` — package-manager hardening (`npm.sh`, `pnpm.sh`, `bun.sh`, `pip.sh`, `cargo.sh`). Set ignore-scripts, minimumReleaseAge, trust policy — supply-chain defenses.
- `kill.sh`, `memtest.sh` — rofi process killer, RAM test.
- `process-helper/`, `systemd-manager/` — Java/Maven projects (jar built to `~/.local/share/...`).

## Quirks

- `harden/` scripts mutate global config files in `$HOME` idempotently — read current state before editing.
- Java subprojects use Maven; committed `target/` is gitignored.

## Conventions

Read `team://knowledge/general-practices` first; for the Java/Maven helpers also read `team://knowledge/spring-conventions`.
