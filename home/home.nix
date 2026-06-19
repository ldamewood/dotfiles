{ pkgs, lib, firefox-addons-pkgs ? { }, ... }:

{
  home.sessionVariables.EDITOR = "nvim";
  home.stateVersion = "25.11";

  # Use linkApps instead of copyApps to avoid macOS "App Management" permission (home-manager 25.11+)
  targets.darwin.copyApps.enable = false;
  targets.darwin.linkApps.enable = true;

  home.packages = with pkgs; [
    btop
    tmux
    gnupg
    jetbrains-mono
    nodejs
    temurin-jre-bin-21
    nixfmt
    nerd-fonts.jetbrains-mono
    nerd-fonts.roboto-mono
    podman
    podman-compose
    zoxide
    lazydocker
    lazygit
    ripgrep
    tree
    pueue
    claude-code
    awscli2

    # Formatters (used by conform-nvim)
    nodePackages.prettier
    stylua
    python3Packages.black
    python3Packages.isort

    # Language servers
    nil
    pyright
    lua-language-server
  ];

  programs.librewolf = {
    enable = true;
    # Enable WebGL, cookies and history
    settings = {
      "webgl.disabled" = false;
      "privacy.resistFingerprinting" = true;
      "privacy.clearOnShutdown.history" = true;
      "privacy.clearOnShutdown.cookies" = true;
      "network.cookie.lifetimePolicy" = 0;
    };
    # Default profile with extensions (e.g. 1Password); from flake extraSpecialArgs
    profiles.default = {
      isDefault = true;
      extensions = lib.mkIf (firefox-addons-pkgs != { }) {
        packages = [
          firefox-addons-pkgs."1password-x-password-manager"
          firefox-addons-pkgs."ublock-origin"
        ];
      };
      settings = {
        # Auto-enable installed extensions
        "extensions.autoDisableScopes" = 0;
      };
    };
  };
  programs.htop.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.yazi = {
    enable = true;
    # New default as of 26.05; set explicitly to silence warning
    shellWrapperName = "y";
  };
  programs._1password-shell-plugins = {
    enable = true;
    plugins = with pkgs; [ gh ];
  };
  nixpkgs = {
    # 1Password CLI and browser extension (NUR pname can include version)
    config.allowUnfreePredicate = pkg:
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
    ./alacritty.nix
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
