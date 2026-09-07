# Baseline home-manager profile shared by every host, including headless
# machines with no GUI apps. Anything a leaf module here depends on
# (zoxide for zsh.nix, ripgrep for neovim.nix's Telescope, formatters/LSPs
# for neovim.nix's conform-nvim config, etc.) must live in this file's
# home.packages so the shared modules work unmodified on any host.
{ pkgs, lib, ... }:

{
  home.sessionVariables.EDITOR = "nvim";
  home.stateVersion = "26.05";

  # Use linkApps instead of copyApps to avoid macOS "App Management" permission (home-manager 25.11+)
  targets.darwin.copyApps.enable = false;
  targets.darwin.linkApps.enable = true;

  home.packages = with pkgs; [
    gnupg
    ripgrep
    zoxide
    nixfmt
    just

    # Formatters (used by conform-nvim)
    prettier
    stylua
    python3Packages.black
    python3Packages.isort

    # Language servers
    nil
    pyright
    lua-language-server
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  nixpkgs = {
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "1password-cli"
        "1password-x-password-manager"
        "claude-code"
      ]
      || lib.hasPrefix "onepassword-password-manager" (lib.getName pkg);
  };

  imports = [
    ./zsh.nix
    ./starship.nix
    ./neovim.nix
    ./claude.nix
    ./tmux.nix
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "liam";
      user.email = "ldamewood@users.noreply.github.com";
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
    };
  };
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
