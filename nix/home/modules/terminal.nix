# Terminal + shell — reuse existing stow configs.
{ pkgs, ... }:
{
  xdg.configFile = {
    "kitty".source = ../../../kitty/.config/kitty;
    "tmux".source = ../../../tmux/.config/tmux;
    # nvim config (Neovim 0.12 vim.pack manager fetches plugins to the writable
    # data dir on first launch, so the read-only store config is fine).
    "nvim".source = ../../../nvim/.config/nvim;
  };

  # .zshrc is antigen-free (no runtime GitHub fetch), safe to reuse verbatim.
  home.file = {
    ".zshrc".source = ../../../zsh/.zshrc;
    ".newsboat".source = ../../../newsboat/.newsboat;

    # Pinned plugins (nixpkgs, hash-locked) sourced by their EXACT store paths —
    # no profile/env-var guessing. syntax-highlighting must come last. .zshrc
    # sources this file if present, else falls back to distro /usr/share (Arch).
    ".config/zsh/nix-plugins.zsh".text = ''
      source ${pkgs.zsh-autosuggestions}/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    '';
  };

  # NOTE: do NOT set programs.zsh.enable here — it would make home-manager
  # generate its own ~/.zshrc, conflicting with the verbatim file above.
  # System-level zsh (login shell + /etc/zshrc) is enabled in common.nix.
}
