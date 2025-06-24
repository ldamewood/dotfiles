{ pkgs, lib, nixops4, ... }:

{
  home.sessionVariables.EDITOR = "nvim";
  home.stateVersion = "25.11";
  home.packages = with pkgs; [
    btop
    tmux
    git
    gnupg
    jetbrains-mono
    nodejs
    nixfmt-rfc-style
    nerd-fonts.jetbrains-mono
    nerd-fonts.roboto-mono
    silver-searcher
    aerospace
    podman
    podman-compose
    zoxide
    lazydocker
    lazygit
    ripgrep
    delta
    tree
    pueue
  ];

  programs.htop.enable = true;
  programs.direnv.enable = true;
  programs.yazi.enable = true;
  programs._1password-shell-plugins = {
    enable = true;
    plugins = with pkgs; [ gh ];
  };
  nixpkgs = {
    config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "1password-cli" ];
  };
  imports = [
    ./zsh.nix
    ./starship.nix
    ./neovim.nix
    ./alacritty.nix
    # ./aerospace.nix
    ./tmux.nix
  ];
}
