# Plan: i3/X11 → Hyprland + Dux Shell

Goal: same muscle memory as i3, more "desktop" (settings UI, control center,
OSDs), tasteful polish. Everything stays in this repo via stow. Delete this
file once phase 6 is done.

Status 2026-10-27: researched + reviewed, nothing installed. Open questions at
the bottom must be answered before the phase that needs them.

Rules for whoever executes this: read `AGENTS.md` and `agents/dotfiles.md`
first. **Never commit, stash or push** — Jan does all git writes. sudo
commands: hand them to Jan, one short command per line. Lua API names below
come from the 0.56 wiki; check each against `/usr/share/hypr/stubs` before use.

## Decisions

| Topic | Choice | Why |
|---|---|---|
| Compositor | Hyprland 0.56 (extra), **Lua config** (`hyprland.lua`) | hyprlang `.conf` deprecated since 0.55, kept only "1–2 releases" |
| Shell | `dms-shell` 1.6.x (extra) now, `dux-shell` 2.0 **as soon as** it reaches extra | 2.0 is days old and only in testing (not enabled here) |
| Greeter / files / terminal | ly, Dolphin (Breeze Dark via kdeglobals), kitty + tmux | unchanged |
| Session start | plain `hyprland.desktop` + own `hyprland-session.target` | same pattern as `i3-session.target`; uwsm would autostart picom, xapp-sn-watcher, EOS welcome from `/etc/xdg/autostart` |
| Colours | fixed scheme; matugen templates for kitty/nvim/Qt off | keep hand-made kitty theme + Breeze |
| Plugins | official + vetted community plugins, only where they beat a built-in or a separate tool; each passes the checklist in "Plugins" below | registry only checks manifest format (+ optional moderator mark); plugins run with full user rights |
| Layout | dwindle; float everything except kitty/firefox (as in i3) | deliberate workflow |
| Updates | `hyprland`, `dms-shell` in `IgnorePkg`; update deliberately after reading release notes | upgrades have broken configs before |

## Phase 0 — repo hygiene (affects nothing at runtime)

- [ ] Jan commits current changes.
- [ ] **`stow-all.sh` → explicit package list.** Today it stows every dir except `ly`, so `agents/ nix/ scripts/ system-check/` leak into `~` (`~/check.sh`, `~/kill.sh`, `~/update.sh` already did). Clean the leaked links after. `mime` and `claude` conflict on real files (`~/.config/mimeapps.list`, `~/.claude/settings.json.bak`) — resolve. `install.sh` runs `sudo bash stow-all.sh` → drop `sudo` (root-owned dirs).
- [ ] **Unfold `~/.config/systemd`** (today a dir symlink into the repo, so every `systemctl --user enable` writes `*.wants/` links into git — that's why the kscreen masks show as untracked). Stow `systemd` with `--no-folding`; commit the kscreen masks (they must stay — see `project_kscreen_modeset`).
- [ ] New packages `hypr` and later `dms` stowed with `--no-folding` too (Dux writes generated files next to ours).
- [ ] `.gitignore`: matugen output in folded dirs (`kitty/.config/kitty/dank-*.conf`, `nvim/.config/nvim/colors/dms.lua`), `hypr/.config/hypr/.dms-backups/`.

## Phase 1 — system prep (i3 must still work after)

- [ ] snapper snapshot before anything else.
- [ ] GPU: `boot_vga` is per-boot luck (2026-10-27 the iGPU won once → black screens under X). Check `cat /sys/bus/pci/devices/0000:03:00.0/boot_vga`; set BIOS (TUF B650-PLUS → Advanced → NB Configuration) Primary Video Adapter = PCIe or iGPU off.
- [ ] X fallback: `sudo cp ~/20-dgpu.conf /etc/X11/xorg.conf.d/` (BusID `PCI:3:0:0`).
- [ ] udev rule for a stable dGPU name (cardN swaps between boots; `AQ_DRM_DEVICES` is colon-separated, so `by-path` names can't be used; `KERNELS==` would also match the simple-framebuffer card):
      `SUBSYSTEM=="drm", KERNEL=="card*", ENV{ID_PATH}=="pci-0000:03:00.0", SYMLINK+="dri/rx9070"`
      Root file like `ly/`. Verify `/dev/dri/rx9070` → the 0x7550 card after reboot.
- [ ] Portals: keep `portals.conf` (`default=gtk`, i3). Add `xdg-desktop-portal/.config/xdg-desktop-portal/hyprland-portals.conf` with `default=hyprland;gtk` — a desktop-specific file in the same dir wins over `portals.conf`.
- [ ] kitty: remove `linux_display_server x11` (would run under XWayland, blurry at 1.5). Check kitty still fine under i3.
- [ ] Install:
      `hyprland xdg-desktop-portal-hyprland dms-shell quickshell matugen dux-gop wl-clipboard wtype satty`
      Optional: `gamescope gamemode gpu-screen-recorder`. Not needed (Dux covers them): hyprlock, hypridle, hyprpolkitagent, cliphist, hyprpicker, grim/slurp.
- Check: i3 starts, screens, screenshare, GTK apps (matugen GTK template will restyle them under i3 too — accepted).

## Phase 2 — minimal Hyprland

`hypr/.config/hypr/`:

```
hyprland.lua    env, require each module; Dux modules via pcall(require, "dms.colors") etc., one per file
monitors.lua    outputs, workspace→monitor
input.lua       kb us,de (",nodeadkeys"), "caps:escape,compose:ralt", follow_mouse = 0
look.lua        general, decoration, animations, group
rules.lua       window + workspace rules
binds.lua       all keybinds
autostart.lua   hyprland.start handler
.luarc.json     → /usr/share/hypr/stubs
```

Env: `AQ_DRM_DEVICES=/dev/dri/rx9070`. Keep `.zprofile` Qt vars (`QT_QPA_PLATFORMTHEME=kde`; ignore Dux's `gtk3` advice — Dolphin turns light). ly lists wayland sessions and its `setup.sh` sources `.zprofile` (verified).

Monitors — match by `desc:` (Wayland connector names differ from X; EDID-verified: DP-2 = Samsung Odyssey G7, DP-3 = iiyama PL2792Q):

| Monitor | Mode | Pos | Scale | Workspaces |
|---|---|---|---|---|
| iiyama PL2792Q (left, primary) | 2560x1440@69.92 | 0x0 | 1 | 1, 2 |
| Samsung Odyssey G7 (right) | 3840x2160@60 (G7 does 144; needs DP1.4 cable) | 2560x0 | 1.5 | 3, 4 |

- Check: `hyprctl systeminfo` = 9070 XT, both screens + rates, audio, kitty bind, `hyprctl configerrors` empty.

## Phase 3 — Dux Shell (1.6 paths!)

- [ ] `dms setup` → writes `~/.config/hypr/dms/*.lua` (1.6: colors, layout, outputs, cursor, binds, windowrules). Our binds stay in `binds.lua`, required after Dux's so ours win. Monitors are owned by our `monitors.lua` (git) — don't require Dux's `outputs.lua`, don't use its display panel to save.
- [ ] Start: `systemctl --user add-wants hyprland-session.target dms` (1.6 way; `dms systemd enable` is 2.0). Our `hyprland.start` runs `dbus-update-activation-environment --systemd --all` then starts `hyprland-session.target` (stowed in `systemd/`; delete it once Hyprland ships its own — merged for 0.57).
- [ ] **Verify dms.service does not hook `graphical-session.target`** — `i3-session.target` BindsTo it, so Dux would start under i3 and break the fallback. If so: drop-in `ConditionEnvironment=WAYLAND_DISPLAY`.
- [ ] Settings live in `~/.config/DankMaterialShell/` on 1.6 (`~/.config/dms/` only from 2.0). **Don't stow Dux settings until the 2.0 move** — paths change; until then a manual backup is enough.
- [ ] Idle: monitor/lock/suspend timeouts 0 (i3 today: no blanking). Night mode manual 4500K (replaces redshift).
- [ ] Wallpaper switcher: Dux built-in (Settings → Wallpaper, `dms ipc call wallpaper next|prev`, per-monitor `nextFor <screen>`). Folder `~/Pictures/wallpapers` with ~20–40 picks from a curated upstream collection, or filled via the Wallpaper Discovery plugin (see Plugins). Images not in git — note the source in `readme.md`. Bind Super+Shift+w → next. Fixed colour scheme stays; matugen-from-wallpaper is an option to try later.
- [ ] Keyring/SSH: check `grep gnome_keyring /etc/pam.d/ly` first. Then `systemctl --user enable gcr-ssh-agent.socket`, export `SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh` in `.zprofile`, delete ssh-agent block `zsh/.zshrc:159-166`.
- [ ] KDE bits stay off under Hyprland: kscreen masks, kded6 statusnotifier setting (`kde/.config/kded6rc`).
- Bar — map every polybar module:

| polybar | Dux |
|---|---|
| workspaces, title, tray, date | built-in |
| volume, eth/wlan, battery | built-in |
| CPU, RAM, disk % | built-in sysmon widgets (dux-gop) |
| Spotify | media widget |
| GPU busy % (`system-gpu.sh`) | 1.6: custom widget if available, else after 2.0 via DankActions |
| focused-window PID (xprop) | drop (process list via dux-gop) |

- Notifications — keep all dunst features: sound on every notification, Slack repeat-alert (`slack-alert.sh`, port from dunstctl/xdotool to `dms ipc` + `hyprctl activewindow -j`), position bottom-right, critical 120 s. Volume stacking is replaced by Dux's OSD.
- Check: bar complete, notifications, `pkexec true`, clipboard history, keyring + ssh, Dolphin dark + Open With, i3 still clean.

## Phase 4 — keybinds and scripts

| i3 | Hyprland / Dux |
|---|---|
| hjkl focus, Shift+hjkl move | `hl.dsp.focus{direction}` / `window.move{direction, group_aware=true}` |
| 1–0, Shift+1–0 (follow) | loop: `focus{workspace=i}` / `window.move{workspace=i, follow=true}` |
| Ctrl+h/l workspace to output | `workspace.move{monitor="l"/"r"}` |
| q kill, Shift+q force kill | `window.close()` / `window.kill()` |
| floating_modifier (Super+drag) | Super+LMB `window.drag()`, Super+RMB `window.resize()`, `{mouse=true}` |
| w tabbed | `group.toggle()` |
| Tab / Shift+Tab focus next/prev (unused) | Super+Tab → overview `dms ipc call hypr toggleOverview`; Alt+Tab / Alt+Shift+Tab → `window.cycle_next` / prev (after 2.0: DankHyprlandWindows switcher) |
| s / v split | `layout("preselect d")` / `("preselect r")` |
| e toggle split | `layout("togglesplit")`, `dwindle.preserve_split=true` |
| f fullscreen, g float | `window.fullscreen`, `window.float` |
| Shift+g float/tile focus toggle | `window.cycle_next{floating=true}` / `{tiled=true}` |
| Shift+f float 1200x800 | float + resize + center |
| r resize mode | submap `resize`, hjkl/arrows, repeating; Esc/Return/Super+r exit |
| minus / Shift+minus scratchpad | `special:scratch` toggle / move |
| d leader submap | submap `scratchpads`: m spotify, n notes, v vol, s slack, b news → `toggle_special(...)`; l → `exec_cmd("hyprctl switchxkblayout all next")`. docs (d) dropped |
| Return | `kitty -e zsh -i -c tmux` (unchanged) |
| BackSpace | `kitty --single-instance` |
| Shift+Return firefox, o dolphin | unchanged |
| p spotify play-pause (used a lot) | `playerctl --player=spotify play-pause`, unchanged |
| space launcher | `dms ipc call spotlight toggle`; rofi stays installed + bound to Super+Shift+space as fallback |
| semicolon emoji | emojiLauncher plugin in spotlight (if vetted), else rofi 2.0 (Wayland) + wtype |
| Shift+v clipboard | `dms ipc call clipboard toggle` |
| Shift+s screenshot | `dms screenshot` (annotate: `dms screenshot --stdout \| satty -f -`) |
| Shift+x colour pick | `dms color pick -a` |
| n / Shift+n notifications | `dms ipc call notifications …` |
| volume / mute / mic keys | `dms ipc call audio increment 5` / `decrement 5` / `mute` / `mic mute` (OSD); drop the `amixer Headphone` part (no Headphone control on the desktop — laptop leftover) |
| media keys | playerctl, `locked=true` |
| Shift+e exit | Dux power menu |
| Shift+c reload, Shift+r restart | auto-reload → drop |
| Dropped | Alt+Shift+m res-toggle (not needed), Ctrl+n nvim-to-ws1 (title match fragile), a focus parent (no dwindle equivalent), Shift+BackSpace (`~/.local/bin/firefox/firefox` gone), Alt+Shift+b/n (scripts gone), button2 kill (no titlebars) |

New binds:

| Bind | Action |
|---|---|
| Super+F1 | keybind cheatsheet (Dux built-in `keybinds` IPC target) |
| Super+c | `dms ipc call control-center toggle` |
| Super+comma | `dms ipc call settings focusOrToggle` |
| Super+Escape | `dms ipc call lock lock` |
| Super+m | `window.fullscreen{mode="maximized"}` (bar stays) |
| Super+y | pin window (all workspaces) |
| Super+grave | previous workspace |
| Print | `dms screenshot full` (Super+Shift+s stays region) |
| Super+Shift+r | gpu-screen-recorder start/stop |
| Super+Shift+w | `dms ipc call wallpaper next` |
| Super+Alt+n | `dms ipc call notifications toggleDoNotDisturb` |
| Super+Alt+g | gaming mode toggle (animations/blur/gaps off) |
| Ctrl+Shift+Esc | process list (Dux default) |

Verify exact IPC function names with `dms ipc call <target>` (lists functions) before binding.

Scratchpads — pure config (`special:<name>` + `on_created_empty` + rules), replaces `quick-launch`/i3ipc:

| Name | Command | Size |
|---|---|---|
| vol | `kitty --class vol -e pulsemixer` | 1400x800 |
| notes | `kitty --class notes -1 -e zsh -lic "nvim ~/notes.md"` | 1400x800 |
| news | `kitty --class news -e newsboat` | 1400x800 |
| spotify | `spotify-launcher` (class `Spotify`, may be set late → `hl.on` workaround) | app default |
| slack | `slack` | app default |

All scratchpads: no border. Other rules: float all except `^(kitty|firefox)$` (center, persistent size); `nvim-float` 1400x900 centered.

Scripts: `language-switch.sh` → kb_layout + leader+l; `autotiling`, `firefox/*`, `res-toggle` → drop; `voice-memo.sh` → drop (delete in phase 6); `kmonad` → already dead (service disabled, device absent), drop its check.

- Check: every bind above, Firefox + Slack screenshare, screenshots, scratchpads.

## Phase 5 — gaming

| Setting | Value |
|---|---|
| VRR | 3 (fullscreen games/video), fallback 2; never 1 (desktop flicker) |
| `general.allow_tearing` | true + `immediate` rule for `steam_app_.*` |
| `render.direct_scanout` | 2 |
| `xwayland.force_zero_scaling` | true if the 4K is fractional |

- Gaming-mode bind (Super+Alt+g): animations/blur/gaps off.
- Check: Steam/Proton, Minecraft, VRR active (`hyprctl monitors`), mangohud.

## Spice — tiers

i3 today is flat black: 0 gaps, near-invisible borders. Jan wants to see what's possible: go up one tier at a time, step back down if too much.

1. Snap for floats, `resize_on_border`, hide cursor on typing, Super+wheel workspaces, `dim_special` 0.3.
2. Rounding 10 + `rounding_power` 4, 2px border, gaps 4/8, no gaps with a single window.
3. Short animations (popin windows, slide workspaces, slidevert scratchpads), blur 1 pass, `dim_inactive = true` + `dim_strength = 0.1`.
4. Shell: floating bar with blur, Control Center, Dash (media, weather, calendar, sysmon), widget lock screen, overview `dms ipc call hypr toggleOverview`, screen recording (gpu-screen-recorder).
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
4. Install from git at a reviewed commit, `dms plugins lock`, commit the lockfile. No auto-updates; on update, read the diff before re-locking.
5. One plugin at a time; remove it if it misbehaves or stops being maintained.

Never: plugins asking to run install scripts, `curl | sh`, or binaries.

## Phase 6 — cleanup (after ~2 weeks daily use; slack-alert port done)

- Remove: `i3-wm i3status python-i3ipc polybar picom dunst redshift snixembed xcolor feh flameshot greenclip`. Keep `rofi`. Keep `xdotool` (rustdesk-bin), `xorg-xsetroot` (tigervnc), `dex` (EOS welcome), `xclip` (rofi-emoji opt) unless those go too.
- Delete in repo: `i3/ i3status/ polybar/ picom/ dunst/ flameshot/ sway/ gestures/ kmonad/`, `i3-session.target`, `portals.conf`, `voice-memo.sh`. Keep `rofi/`.
- Update `install.sh`, `readme.md` (greenclip stale), `agents/dotfiles.md`, `.zprofile` comments, `ei3` alias.
- nix port references i3 (`nix/hosts/common.nix`, `nix/home/modules/wm.nix`) — separate task.
- Move to `dux-shell` once in extra: settings move to `~/.config/dms/` → stow file-level now (`settings.json`, `plugins.lock.json`; never `~/.local/state/dms`, `~/.cache/dms`). 2.0's `dms setup` writes its own `hyprland-session.target` → conflicts with ours, remove one. App ID for floating windows stays `com.danklinux.dms`.

## Risks

| Risk | Mitigation |
|---|---|
| Dux 2.0 fresh, open bugs (lock, tray) | stay on 1.6 until 2.0.x is in extra |
| Hyprland breaking changes | Lua only; IgnorePkg + release notes; `hyprctl configerrors` after update; snapper |
| Wrong GPU | udev `ID_PATH` symlink + `AQ_DRM_DEVICES`; BIOS |
| Apps replace stowed symlinks (tmp+rename) | `git status` after settings changes |
| Dux starts under i3 | check unit hooks in phase 3 |
| Rollback | pick i3 in ly — untouched until phase 6 |

## Answered (2026-10-27)

4K scale 1.5, 1440p 1 · polish tiers upward · Super+Tab overview, Alt+Tab cycle · volume 5 %, amixer dropped · keep notification sound + Slack alert · voice-memo dropped · try Dux launcher, keep rofi · Dux wallpaper switcher + curated folder · monitors in git · dux-shell 2.0 as soon as it's in extra.

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
- https://github.com/duxlabs-dev/dux-docs (versioned_docs/version-1.6)
- https://github.com/duxlabs-dev/dux-plugins
- https://github.com/rochacbruno/DankCalculator
- https://plugins.danklinux.com/emoji-unicode-launcher.html
- https://duxlabs.dev/plugins
- https://github.com/duxlabs-dev/dux-plugin-registry/blob/master/MODERATION.md
- https://archlinux.org/packages/extra/x86_64/dux-gop/
- https://www.electronjs.org/docs/latest/breaking-changes
