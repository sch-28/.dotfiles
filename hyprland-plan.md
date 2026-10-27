# Plan: i3/X11 → Hyprland + Dux Shell

Goal: same muscle memory as i3, more "desktop" (settings UI, control center,
OSDs), tasteful polish. Everything stays in this repo via stow. Delete this
file once phase 6 is done.

Status 2026-10-27: phases 0–5 and spice tiers 1–4 done, reviewed twice; Hyprland is the daily session. Phase 6 (cleanup) after ~2 weeks. Open questions at
the bottom must be answered before the phase that needs them.

Rules for whoever executes this: read `AGENTS.md` and `agents/dotfiles.md`
first. **Never commit, stash or push** — Jan does all git writes. sudo
commands: hand them to Jan, one short command per line. Lua API names below
come from the 0.56 wiki; check each against `/usr/share/hypr/stubs` before use.

## Decisions

| Topic | Choice | Why |
|---|---|---|
| Compositor | Hyprland 0.56 (extra), **Lua config** (`hyprland.lua`) | hyprlang `.conf` deprecated since 0.55, kept only "1–2 releases" |
| Shell | `dux-shell` 2.0 via `pacman -U` from extra-testing (switched 2026-10-27, mid phase 3); plain `pacman -S` once in extra | 1.6 → 2.0 later would have redone phase 3 (paths, session, binds); rollback = `pacman -S dms-shell` + `~/.local/share/dms-1.6-backup-2026-10-27` |
| Greeter / files / terminal | ly, Dolphin (Breeze Dark via kdeglobals), kitty + tmux | unchanged |
| Session start | plain `hyprland.desktop` + own `hyprland-session.target` | same pattern as `i3-session.target`; uwsm would autostart picom, xapp-sn-watcher, EOS welcome from `/etc/xdg/autostart` |
| Colours | fixed scheme (Dux theme `monochrome`, no wallpaper theming); kitty includes no `dank-*.conf` (generated, gitignored, inert) | keep hand-made kitty theme + Breeze |
| Plugins | official + vetted community plugins, only where they beat a built-in or a separate tool; each passes the checklist in "Plugins" below | registry only checks manifest format (+ optional moderator mark); plugins run with full user rights |
| Layout | dwindle; float everything except kitty/firefox (as in i3) | deliberate workflow |
| Updates | `snap-pac` (pre/post snapshot of `/` around every pacman transaction; `snap-pac/etc/snap-pac.ini` maps its default `root` to our `root-config`) + read Hyprland/Dux release notes before `-Syu`. No IgnorePkg | rollback instead of blocked `-Syu` (hypr* lib soname bumps) |

## Phase 0 — repo hygiene (affects nothing at runtime)

- [x] Jan commits current changes.
- [x] **`stow-all.sh` → explicit package list.** Today it stows every dir except `ly`, so `agents/ nix/ scripts/ system-check/` leak into `~` (`~/check.sh`, `~/kill.sh`, `~/update.sh` already did). Clean the leaked links after. `mime` and `claude` conflict on real files (`~/.config/mimeapps.list`, `~/.claude/settings.json.bak`) — resolve. `install.sh` runs `sudo bash stow-all.sh` → drop `sudo` (root-owned dirs).
- [x] **Unfold `~/.config/systemd`** (today a dir symlink into the repo, so every `systemctl --user enable` writes `*.wants/` links into git — that's why the kscreen masks show as untracked). Stow `systemd` with `--no-folding`. kscreen masks must stay (see `project_kscreen_modeset`). Stow refuses `/dev/null` links → `install.sh` runs `systemctl --user mask plasma-kscreen.service plasma-kscreen-osd.service`. Verify: `systemctl --user is-enabled plasma-kscreen.service` = `masked`.
- [x] New packages `hypr` and later `dms` stowed with `--no-folding` too (Dux writes generated files next to ours).
- [x] `.gitignore`: matugen output in folded dirs (`kitty/.config/kitty/dank-*.conf`, `nvim/.config/nvim/colors/dms.lua`), `hypr/.config/hypr/.dms-backups/`.

## Phase 1 — system prep (i3 must still work after)

- [x] snapper snapshot before anything else.
- [x] GPU: `boot_vga` is per-boot luck (2026-10-27 the iGPU won once → black screens under X). Check `cat /sys/bus/pci/devices/0000:03:00.0/boot_vga`; set BIOS (TUF B650-PLUS → Advanced → NB Configuration) Primary Video Adapter = PCIe or iGPU off.
- [x] X fallback: `gpu/etc/X11/xorg.conf.d/20-dgpu.conf`, copied by `install.sh` (BusID `PCI:3:0:0`).
- [x] udev rule for a stable dGPU name (cardN swaps between boots; `AQ_DRM_DEVICES` is colon-separated, so `by-path` names can't be used; `KERNELS==` would also match the simple-framebuffer card):
      `SUBSYSTEM=="drm", KERNEL=="card*", ENV{ID_PATH}=="pci-0000:03:00.0", SYMLINK+="dri/rx9070"`
      `gpu/etc/udev/rules.d/90-rx9070.rules`, copied (not stowed: udev reads rules before /home is mounted) by `install.sh`. Verify `/dev/dri/rx9070` → the 0x7550 card after reboot.
- [x] Portals: keep `portals.conf` (`default=gtk`, i3). Add `xdg-desktop-portal/.config/xdg-desktop-portal/hyprland-portals.conf` with `default=hyprland;gtk` — a desktop-specific file in the same dir wins over `portals.conf`.
- [x] kitty: remove `linux_display_server x11` (would run under XWayland, blurry at 1.5). Check kitty still fine under i3.
- [x] Install:
      `hyprland xdg-desktop-portal-hyprland dux-shell (2.0, see Decisions) quickshell matugen dux-gop wl-clipboard wtype satty`
      Optional: `gamescope gamemode gpu-screen-recorder`. Not needed (Dux covers them): hyprlock, hypridle, hyprpolkitagent, cliphist, hyprpicker, grim/slurp.
- Check: i3 starts, screens, screenshare, GTK apps (matugen GTK template will restyle them under i3 too — accepted).

## Phase 2 — minimal Hyprland

`hypr/.config/hypr/`:

```
hyprland.lua    env (AQ_DRM_DEVICES only if /dev/dri/rx9070 exists), Dux modules via pcall (broken ones notify), require each module
monitors.lua    outputs, workspace→monitor
input.lua       kb de,us ("nodeadkeys,"), "caps:escape" (no compose:ralt: AltGr needed on de), follow_mouse = 2 (X-like: scroll under cursor, keyboard focus on click)
look.lua        general, decoration, animations, render, smart-gap workspace rules
rules.lua       scratchpad app list + window/workspace rules (returns the list)
binds.lua       all keybinds
scratchpad.lua  i3-style scratchpads (store in special:<name>, fetch to current workspace)
autostart.lua   hyprland.start / hyprland.shutdown handlers (session target)
.luarc.json     → /usr/share/hypr/stubs
scripts/        record.sh, slack-alert-watch.sh, slack-alert.sh + .wav
```

Env: `AQ_DRM_DEVICES=/dev/dri/rx9070`. Keep `.zprofile` Qt vars (`QT_QPA_PLATFORMTHEME=kde`; ignore Dux's `gtk3` advice — Dolphin turns light). ly lists wayland sessions and its `setup.sh` sources `.zprofile` (verified).

Monitors — match by `desc:` (Wayland connector names differ from X; EDID-verified: DP-2 = Samsung Odyssey G7, DP-3 = iiyama PL2792Q):

| Monitor | Mode | Pos | Scale | Workspaces |
|---|---|---|---|---|
| iiyama PL2792Q (left, primary) | 2560x1440@69.92 | 0x0 | 1 | 1, 2 |
| Samsung Odyssey G7 (right) | 3840x2160@60 (144 available on current cable; 60 by choice, not used for gaming) | 2560x0 | 1.5 | 3, 4 |

- Check: `hyprctl systeminfo` = 9070 XT, both screens + rates, audio, kitty bind, `hyprctl configerrors` empty.

## Phase 3 — Dux Shell (2.0, `~/.config/dms/`)

- [x] `dms setup <module>` per module (colors layout cursor binds windowrules), **never bare `dms setup`**: it rewrites `hyprland.lua` (a symlink into git) and deploys a terminal config. Fragments land in `~/.config/hypr/dms/` (unfolded, not in git); Settings → Keyboard Shortcuts writes `dms/binds-user.lua`. Our `binds.lua` unbinds each key before binding (duplicates would both fire). Our binds stay in `binds.lua`, required after Dux's so ours win. Monitors are owned by our `monitors.lua` (git) — don't require Dux's `outputs.lua`, don't use its display panel to save.
- [x] Start: `systemctl --user add-wants hyprland-session.target dms.service` (same as 2.0's `dms systemd enable`; in `install.sh`). `autostart.lua` pushes the env (`--all`), stops `i3-session.target`, `reset-failed dms`, then **restarts** `hyprland-session.target` (plain start is a no-op if a previous session left it up); `hyprland.shutdown` stops it. Delete our target once Hyprland ships its own (merged for 0.57).
- [x] **Session state survives logout** (user manager outlives logins via tmux): each session cleans up after the other at start — i3's single `exec_always sh -c` unsets `WAYLAND_DISPLAY`/`HYPRLAND_INSTANCE_SIGNATURE`, pushes its env incl. `XDG_SESSION_TYPE`, stops `hyprland-session.target`, starts `i3-session.target` (one `sh -c`: separate exec_always lines race).
- [x] **dms.service hooks `graphical-session.target`** (`WantedBy=`, `PartOf=`, `Requisite=`; preset enabled → never `preset-all`). Drop-in `dms.service.d/hyprland-only.conf`: `PartOf=hyprland-session.target` + `ConditionEnvironment=XDG_CURRENT_DESKTOP=Hyprland` (not `WAYLAND_DISPLAY` — it lingers in the manager env). Same trick reversed for dunst (`dunst.service.d/i3-only.conf`) so D-Bus activation can't grab the notification name under Hyprland.
- [x] Settings: `~/.config/dms/` (2.0 migrated it; `~/.config/DankMaterialShell` is a compat symlink). Stowed file-level in package `dms`: `settings.json`, `plugin_settings.json` (symlinks survive Dux writes — tested for settings.json). `plugins.lock.json` is **not** stowed (lock replaces symlinks), see Plugins. 2.0 migration had set `island: true` on the main bar; Jan later switched to a plain bottom bar (`island: false`, position bottom).
- [x] Idle: monitor/lock/suspend timeouts 0 (defaults). Night mode manual 5100K (Jan's pick; replaces redshift) — lives in `~/.local/state/dms/session.json`, not in git.
- [x] Wallpaper: ~620 images in `~/Pictures/wallpapers`, all landscape ≥ 2560 px: elementary + KDE Plasma (curated, no AI), dharmx/walls (nature/minimal/architecture/anime groups), Wallhaven toplist 15× landscape/minimalism/space/city (AI filtered). Fetched by `scripts/fetch-wallpapers.py` (not in git; replaced the D3Ext set, too many low-res/AI images). Super+Shift+w = Wallpaper Carousel plugin, Super+Ctrl+w = next. Fixed colour scheme stays.
- [x] Keyring/SSH: `pam.d/ly` has pam_gnome_keyring; `gcr-ssh-agent.socket` enabled (in `install.sh`); `.zprofile` sets `SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh` unless already set (keeps `ssh -A`); old ssh-agent block removed from `.zshrc`.
- [x] KDE bits stay off under Hyprland: kscreen masks (verify `systemctl --user is-enabled plasma-kscreen.service` = `masked`), kded6 statusnotifier setting (`kde/.config/kded6rc`).
- Bar — map every polybar module:

| polybar | Dux |
|---|---|
| workspaces, title, tray, date | built-in |
| volume, eth/wlan, battery | built-in |
| CPU, RAM, disk % | built-in sysmon widgets (dux-gop) |
| Spotify | media widget |
| GPU busy % (`system-gpu.sh`) | GPU temp widget now; busy % via DankActions plugin (2.0) if wanted |
| focused-window PID (xprop) | drop (process list via dux-gop) |

- Notifications — bottom-right popups with sound (Dux). Critical ones went to the island while it was on (now bottom bar) and stay until dismissed. Slack: Dux rule `appName == Slack → critical` + `hypr/.config/hypr/scripts/slack-alert-watch.sh` (dbus-monitor, user unit `slack-alert-watch.service`, hyprland-session only) runs `slack-alert.sh` (beeps `slack-alert.wav` until closed / Slack focused / 30 s). Volume stacking is replaced by Dux's OSD.
- Check (done 2026-10-27): bar complete, notifications + sound, `pkexec true`, clipboard history, Dolphin dark + Open With, i3 still clean, SSH via gcr under i3.

## Phase 4 — keybinds and scripts

| i3 | Hyprland / Dux |
|---|---|
| hjkl focus, Shift+hjkl move | `hl.dsp.focus{direction}` / `window.move{direction, group_aware=true}` |
| 1–0, Shift+1–0 (follow) | loop: `focus{workspace=i}` / `window.move{workspace=i, follow=true}` |
| Ctrl+h/l workspace to output | `workspace.move{monitor="l"/"r"}` |
| q kill, Shift+q force kill | `window.close()` / `window.kill()` |
| floating_modifier (Super+drag) | Super+LMB `window.drag()`, Super+RMB `window.resize()`, `{mouse=true}` |
| w tabbed | `group.toggle()` |
| Tab / Shift+Tab focus next/prev (unused) | Super+Tab → overview `dms ipc call hypr toggleOverview`; Alt+Tab → last focused window (any workspace, `focus{last}`); Alt+Shift+Tab → `cycle_next` within the workspace |
| s / v split | `layout("preselect d")` / `("preselect r")` |
| e toggle split | `layout("togglesplit")`, `dwindle.preserve_split=true` |
| f fullscreen, g float | `window.fullscreen`, `window.float` |
| Shift+g float/tile focus toggle | `window.cycle_next{floating=true}` / `{tiled=true}` |
| Shift+f float 1200x800 | toggle: float + resize + center, or back to tiled |
| r resize mode | submap `resize`, hjkl/arrows, repeating; Esc/Return/Super+r exit |
| minus / Shift+minus scratchpad | `scratchpad.scratch()` / `stash()` in scratchpad.lua (see Scratchpads below) |
| d leader submap | submap `leader`: m spotify, n notes, v vol, s slack, b news → `scratchpad.toggle(name)`; l → `hyprctl switchxkblayout all next`; any other key exits (catchall). docs (d) dropped |
| Return | `kitty -e zsh -i -c tmux` (unchanged) |
| BackSpace | `kitty --single-instance` |
| Shift+Return firefox, o dolphin | unchanged |
| p spotify play-pause (used a lot) | `playerctl --player=spotify play-pause`; starts `spotify-launcher` (into its scratchpad) if no Spotify window |
| space launcher | `dms ipc call spotlight toggle`; rofi stays installed + bound to Super+Shift+space as fallback |
| semicolon emoji | rofi 2.0 (Wayland) emoji on `code:47` (physical US ; = ö on de: binds resolve on the first layout, de) |
| v clipboard (Shift+v preselect right) | `dms ipc call clipboard toggle` |
| Shift+s screenshot | `dms screenshot` (annotate: `dms screenshot --stdout \| satty -f -`) |
| Shift+x colour pick | `dms color pick -a` |
| n / Shift+n notifications | `dms ipc call notifications …` |
| volume / mute / mic keys | `dms ipc call audio increment 5` / `decrement 5` / `mute` / `micmute` (OSD); drop the `amixer Headphone` part (no Headphone control on the desktop — laptop leftover) |
| media keys | playerctl, `locked=true` |
| Shift+e exit | Dux power menu |
| Shift+c reload, Shift+r restart | auto-reload → drop |
| Dropped | Alt+Shift+m res-toggle (not needed), Ctrl+n nvim-to-ws1 (title match fragile), a focus parent (no dwindle equivalent), Shift+BackSpace (`~/.local/bin/firefox/firefox` gone), Alt+Shift+b/n (scripts gone), button2 kill (no titlebars) |

New binds:

| Bind | Action |
|---|---|
| Super+F1 | keybind cheatsheet (Dux built-in `keybinds` IPC target) |
| Super+c | `dms ipc call control-center toggle` |
| Super+a | `dms ipc call dash toggle ""` (empty tab = overview; Dash: media, weather, calendar, sysmon) |
| Super+comma | `dms ipc call settings focusOrToggle` |
| Super+Escape | `dms ipc call lock lock` |
| Super+m | `window.fullscreen{mode="maximized"}` (bar stays) |
| Super+y | pin window (all workspaces) |
| Super+code:49 | previous workspace (physical key left of 1; `grave` never fires on de) |
| Print | `dms screenshot full` (Super+Shift+s stays region) |
| Super+Shift+r | `scripts/record.sh`: gpu-screen-recorder on the focused monitor + desktop audio → `~/Videos/rec-*.mp4`, toggle via SIGINT (`pkill -f`: name > 15 chars) |
| Super+Shift+w | wallpaper carousel `dms ipc call wallpaperCarousel toggle` (plugin, reviewed) · Super+Ctrl+w `wallpaper next` |
| Super+Alt+n | `dms ipc call notifications toggleDoNotDisturb` |
| Super+Alt+g | gaming mode — dropped (Jan: not wanted, even with tier 3 animations/blur) |
| Ctrl+Shift+Esc | process list (Dux default) |

Verify exact IPC function names with `dms ipc --help` before binding. Unbound Dux defaults: `Super+Shift+P` (DPMS off), `Ctrl+Shift+R` and `Alt+Space` (no Super — stole app shortcuts).

Scratchpads — `scratchpad.lua` (i3 semantics): `special:<name>` is only the hidden store; leader key fetches the window onto the current workspace as a normal floating window (usable alongside others), again hides it, starts the app if needed. Spotify alone uses the special-workspace overlay (Jan's pick). Super+minus / Super+Shift+minus: same for any window (tag `scratch`; Shift+minus on a fetched one releases it):

| Name | Command | Size |
|---|---|---|
| vol | `kitty --class vol -e pulsemixer` | 1400x800 |
| notes | `kitty --class notes -1 -e zsh -lic "nvim ~/notes.md"` | 1400x800 |
| news | `kitty --class news -e newsboat` | 1400x800 |
| spotify | `spotify-launcher` (class `Spotify`, may be set late → `hl.on` workaround) | app default |
| slack | `slack` | 1600x1000 (`suppress_event = maximize`: Slack restores its maximized state, which tiled it) |

All scratchpads: no border. Other rules: float all except `^(kitty|firefox)$` (center, persistent size); `nvim-float` 1400x900 centered. Global `suppress_event = maximize` (like i3: kitty/Slack maximize requests on open covered the workspace).

Scripts: `language-switch.sh` → kb_layout + leader+l; `autotiling`, `firefox/*`, `res-toggle` → drop; `voice-memo.sh` → drop (delete in phase 6); `kmonad` → already dead (service disabled, device absent), drop its check.

- Check: every bind above, Firefox + Slack screenshare, screenshots, scratchpads.

## Phase 5 — gaming

| Setting | Value |
|---|---|
| VRR | skipped (Jan, 2026-10-27). If wanted later: 3 (fullscreen games/video), never 1 (desktop flicker); EDID ranges iiyama 48–70 Hz, G7 55–144 Hz (runs 60) |
| `general.allow_tearing` | skipped (no competitive shooters); would be true + `immediate` rule for `steam_app_.*` |
| `render.direct_scanout` | 2 (auto: content type game) — done, `look.lua` |
| `xwayland.force_zero_scaling` | not needed: Jan games only on the iiyama (scale 1) |

- Gaming-mode bind: dropped (Jan, 2026-10-27).
- Check: Steam/Proton, Minecraft, mangohud.

## Spice — tiers

i3 today is flat black: 0 gaps, near-invisible borders (Hyprland tier 0: borders 0 — over a wallpaper the dark i3 borders read as frames). Jan wants to see what's possible: go up one tier at a time, step back down if too much.

1. Snap for floats, `resize_on_border`, hide cursor on typing, Super+wheel workspaces (from Dux's ungitted `dms/binds.lua`), `dim_special` 0.3. — done: snap 40 px, edge grab 25 px.
2. Rounding 10 + `rounding_power` 4, 2px border, gaps 4/8, no gaps with a single window. — tried, then dropped entirely (Jan): no rounding, border or gaps.
3. Short animations (popin windows, slide workspaces, slidevert scratchpads), blur 1 pass, `dim_inactive = true` + `dim_strength = 0.1`. — done without dim (Jan: no focused/unfocused difference): popin/slide/slidevert ~150–250 ms, blur size 6 × 1 pass, layer animations off (Dux animates its own).
4. Shell: floating bar with blur, Control Center, Dash (media, weather, calendar, sysmon), widget lock screen, overview `dms ipc call hypr toggleOverview`, screen recording (gpu-screen-recorder). — done: bar (Jan's: bottom, detached, square) 85 % + Dux `blurEnabled`; Dash on Super+a (Dux's Super+y is our pin); lock screen = Dux defaults.
5. Plugins — see below.

Avoid: looping border animation (constant redraw), hyprpm (Hyprland compositor) plugins (rebuild every update).

## Plugins

Candidates — add one at a time, only if it beats what's built in:

| Plugin | Source | Replaces / adds | When |
|---|---|---|---|
| DankLauncherKeys | official | keybind cheatsheet in launcher | 2.0 (`requires_dms >= 2.0`) |
| DankHyprlandWindows | official | Alt+Tab switcher with live previews | 2.0 |
| DankActions | official | custom bar buttons (GPU busy %/temp, replaces `system-gpu.sh`) | 2.0 |
| Calculator | community, rochacbruno/DankCalculator | `=` calc in launcher | check `requires_dms` |
| emojiLauncher | community, devnullvoid | emoji in launcher → rofi only as fallback | check `requires_dms` |
| Wallpaper Discovery | community | search + download wallpapers into a folder, feeds the built-in switcher | check `requires_dms`; network access |

Checklist before installing (Claude can do the review):

1. Maintained (commits in the last months), visible author, upvotes/stars, issues answered.
2. Small enough to read in full. Read every `.qml`/`.js`: look for `Process`/`exec`/shell calls, network URLs, file access outside its own dir, downloads of code at runtime. Network only to the service it's about (e.g. wallpaper provider).
3. `plugin.json`: `requires_dms` fits the installed version; declared permissions match what the code does.
4. Install from git at a reviewed commit, then `dms plugins lock -o ~/.dotfiles/dms/plugins.lock.json` (lock replaces symlinks, so the repo copy is not stowed; `install.sh` restores from it). No auto-updates; on update, read the diff before re-locking.
5. One plugin at a time; remove it if it misbehaves or stops being maintained.

Never: plugins asking to run install scripts, `curl | sh`, or binaries.

Installed (reviewed 2026-10-27, pinned in `dms/plugins.lock.json`):

| Plugin | Commit | Verdict |
|---|---|---|
| Wallpaper Carousel (motor-dev) | 761ecd1 | safe: no processes/network; Super+Shift+w |
| Docker Manager (LuckShiba) | f6f7d94 | safe: docker CLI only, args quoted; terminal `kitty --hold` |
| AiOverviewControl (bernardopg) | cb3724c | safe with notes: Claude provider only (Jan's call) — reads `~/.claude/.credentials.json` token, sends it only to api.anthropic.com with a spoofed `claude-cli` User-Agent; also fetches LiteLLM pricing (GitHub raw) + frankfurter.dev rates; "reset limits" button spends a real credit |

## Phase 6 — cleanup (after ~2 weeks daily use; slack-alert port done)

- Remove: `i3-wm i3status python-i3ipc polybar picom dunst redshift snixembed xcolor feh flameshot greenclip`. Keep `rofi`. Keep `xdotool` (rustdesk-bin), `xorg-xsetroot` (tigervnc), `dex` (EOS welcome), `xclip` (rofi-emoji opt) unless those go too. `mime/.config/mimeapps.list` still points image/png at `feh.desktop` — replace.
- Delete in repo: `i3/ i3status/ polybar/ picom/ dunst/ flameshot/ sway/ gestures/ kmonad/`, `i3-session.target`, `dunst.service.d/`, `portals.conf`, `voice-memo.sh`, kitty `session-${XDG_SESSION_TYPE}` include (Wayland-only then: plain `font_size 14`). Keep `rofi/`.
- Update `install.sh`, `readme.md` (greenclip stale), `agents/dotfiles.md`, `.zprofile` comments, `ei3` alias.
- nix port references i3 (`nix/hosts/common.nix`, `nix/home/modules/wm.nix`) — separate task.
- Once `dux-shell` is in extra: `install.sh` → `pacman -S dux-shell` instead of the extra-testing URL. 2.0's full `dms setup` would write its own `hyprland-session.target` — never run it bare (see phase 3).

## Risks

| Risk | Mitigation |
|---|---|
| Dux 2.0 fresh, open bugs (lock, tray) | running it since 2026-10-27; rollback `pacman -S dms-shell` + 1.6 backup in `~/.local/share/` |
| Hyprland breaking changes | Lua only; snap-pac pre/post snapshots + release notes; `hyprctl configerrors` after update; snapper |
| Wrong GPU | udev `ID_PATH` symlink + `AQ_DRM_DEVICES`; BIOS |
| Apps replace stowed symlinks (tmp+rename) | `git status` after settings changes; `dms plugins lock` does it (lockfile kept unstowed) |
| Dux starts under i3 | drop-in condition + i3 stops `hyprland-session.target` at start (phase 3) |
| Rollback | pick i3 in ly — untouched until phase 6 |

## Answered (2026-10-27)

4K scale 1.5, 1440p 1 · polish tiers upward · Super+Tab overview, Alt+Tab cycle · volume 5 %, amixer dropped · keep notification sound + Slack alert · voice-memo dropped · try Dux launcher, keep rofi · Dux wallpaper switcher + curated folder · monitors in git · dux-shell 2.0 as soon as it's in extra. — superseded today where later decisions differ (Alt+Tab = last window, wallpaper sources, dux-shell 2.0 from extra-testing).

## Sources

- https://hypr.land/news/26_lua/
- https://wiki.hypr.land/0.56.0/Configuring/Basics/Binds/
- https://wiki.hypr.land/0.56.0/Configuring/Basics/Dispatchers/
- https://wiki.hypr.land/0.56.0/Configuring/Basics/Variables/
- https://wiki.hypr.land/Configuring/Basics/Window-Rules/
- https://wiki.hypr.land/Configuring/Basics/Monitors/
- https://wiki.hypr.land/configuring/extra/multi-gpu/
- https://wiki.hypr.land/configuring/extra/tearing/
- https://wiki.hypr.land/0.56.0/Useful-Utilities/Systemd-start/
- https://duxlabs.dev/docs/dms/compositors
- https://duxlabs.dev/docs/dms/installation
- https://duxlabs.dev/docs/dms/keybinds-ipc
- https://duxlabs.dev/docs/dms/application-themes
- https://duxlabs.dev/docs/dms/plugins-overview
- https://duxlabs.dev/blog/v2-0-release
- https://github.com/duxlabs-dev/dux-docs (1.6 docs, used before the 2.0 switch)
- https://github.com/duxlabs-dev/dux-plugins
- https://github.com/rochacbruno/DankCalculator
- https://duxlabs.dev/plugins
- https://github.com/duxlabs-dev/dux-plugin-registry/blob/master/MODERATION.md
- https://archlinux.org/packages/extra/x86_64/dux-gop/
- https://github.com/elementary/wallpapers
- https://invent.kde.org/plasma/plasma-workspace-wallpapers
- https://github.com/dharmx/walls
- https://wallhaven.cc/help/api
- https://www.electronjs.org/docs/latest/breaking-changes
