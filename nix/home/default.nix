# home-manager entry for user jan.
# Imports feature modules. Add a file under modules/ + a line here to extend.
{ ... }:
{
  imports = [
    ./modules/wm.nix # i3, polybar, rofi, dunst, picom — reused from stow dirs
    ./modules/terminal.nix # kitty, tmux, zsh, fzf
    ./modules/packages.nix # all user apps + cli tools (mapped from pacman -Qe)
  ];

  home.username = "jan";
  home.homeDirectory = "/home/jan";
  home.stateVersion = "25.11"; # do NOT change after first switch

  programs.home-manager.enable = true;
}
