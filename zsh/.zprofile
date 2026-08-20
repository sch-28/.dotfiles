# Sourced by the login shell. ly execs the session through one, so this env reaches
# i3 and everything i3/rofi spawns. (That is ly's own behaviour, not the `shell`
# key in its config.ini -- that one only toggles the shell entry in the session
# list.) i3 forwards the two vars below to the D-Bus/systemd activation env too,
# see i3/.config/i3/config.

# KDE/Qt apps (dolphin, etc.) skip plasma-integration when XDG_CURRENT_DESKTOP
# is not KDE, and fall back to a light Fusion palette. Force it so they read
# ~/.config/kdeglobals.
export QT_QPA_PLATFORMTHEME=kde

# kbuildsycoca6 indexes applications from /etc/xdg/menus/${XDG_MENU_PREFIX}applications.menu.
# Arch ships no unprefixed applications.menu, so without this nothing matches and
# KDE's service DB ends up with zero apps -- "Open With" comes up empty.
# arch- (archlinux-xdg-menu) instead of plasma- so this needs no plasma-workspace.
export XDG_MENU_PREFIX=arch-
