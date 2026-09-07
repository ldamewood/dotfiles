# Extras for an interactive, GUI-capable dev workstation (mbp). Layered on
# top of ./common.nix. Not imported on headless hosts.
{
  pkgs,
  lib,
  firefox-addons-pkgs ? { },
  ...
}:

{
  home.packages = with pkgs; [
    btop
    tmux
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.roboto-mono
    nodejs
    temurin-jre-bin-21
    podman
    podman-compose
    lazydocker
    lazygit
    tree
    pueue
    awscli2
    uv
    herdr
  ];

  # atomic (https://bastani.ai/) isn't packaged in nixpkgs; it's an npm-only
  # CLI, so keep it up to date via a home-manager activation hook instead.
  # nodejs's own store path is read-only, so point npm's global prefix at a
  # writable dir in $HOME and put its bin/ on PATH.
  home.activation.installAtomicCli = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    export PATH="${pkgs.nodejs}/bin:$PATH"
    run mkdir -p "$NPM_CONFIG_PREFIX"
    run ${pkgs.nodejs}/bin/npm install -g @bastani/atomic
  '';

  home.sessionPath = [ "$HOME/.npm-global/bin" ];

  # 1Password's SSH agent socket, provided by the 1Password desktop app.
  programs.zsh.initContent = ''
    export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  '';

  imports = [ ./alacritty.nix ];

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
  programs.yazi = {
    enable = true;
  };
  programs._1password-shell-plugins = {
    enable = true;
    plugins = with pkgs; [ gh ];
  };
}
