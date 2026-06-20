{ pkgs, lib, ... }:

{
  # Allow 1Password CLI and browser extension (NUR addon name can include version)
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "1password-cli" "1password-x-password-manager" ]
    || lib.hasPrefix "onepassword-password-manager" (lib.getName pkg);

  environment.systemPackages = [
    pkgs.vim
  ];

  users.users.liam = {
    home = "/Users/liam";
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "liam" ];
    system-features = [
      "nixos-test"
      "apple-virt"
    ];
  };

  programs.zsh.enable = true;

  # SSH configuration for linux-builder
  programs.ssh.extraConfig = ''
    Host linux-builder
      Hostname localhost
      HostKeyAlias linux-builder
      Port 31022
      IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  '';

  system.stateVersion = 5;

  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = "liam";

  # Enable Touch ID support for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # System settings
  system.defaults = {
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    loginwindow.LoginwindowText = "REWARD IF LOST: ldamewood@users.noreply.github.com";

    # Dock
    dock = {
      autohide = true;
      mru-spaces = false;
      persistent-apps = [
        "/System/Applications/Apps.app"
        "${pkgs.alacritty}/Applications/Alacritty.app"
        "/System/Applications/Utilities/Activity Monitor.app"
        "${pkgs.librewolf}/Applications/LibreWolf.app"
        "/System/Applications/System Settings.app"
        "/Applications/Visual Studio Code.app"
      ];
    };
  };
    
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    casks = [
      "1password"
      "1password-cli"
      "github"
      "google-chrome"
      "docker-desktop"
      "wezterm"
      "plex"
      "parallels"
      "minecraft"
      "steam"
      "visual-studio-code"
      "nordvpn"
      "vlc"
      "cryptomator"
    ];
  };
}
