# WM stack — REUSE existing stow configs verbatim via symlink-into-store.
# Edit the real files under .dotfiles/<app>/, then `nixos-rebuild switch` to
# pick up changes. To go native later, swap a block for programs.<app> / etc.
#
# Paths are relative to this file: ../../../ == .dotfiles repo root.
{ ... }:
{
  xdg.configFile = {
    "i3".source = ../../../i3/.config/i3;
    "polybar".source = ../../../polybar/.config/polybar;
    "rofi".source = ../../../rofi/.config/rofi;
    "dunst".source = ../../../dunst/.config/dunst;
    "picom".source = ../../../picom/.config/picom;
    "flameshot".source = ../../../flameshot/.config/flameshot;
  };

  # gestures config lives at ~/.config/libinput-gestures.conf (single file)
  xdg.configFile."libinput-gestures.conf".source =
    ../../../gestures/.config/libinput-gestures.conf;

  # Autostart libinput-gestures via dex (i3 runs `dex --autostart`), same as Arch.
  xdg.configFile."autostart/libinput-gestures.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=libinput-gestures
    Exec=libinput-gestures
    X-GNOME-Autostart-enabled=true
  '';
}
