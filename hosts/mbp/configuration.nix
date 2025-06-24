{ pkgs, lib, ... }:

{
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
        "/System/Applications/Launchpad.app"
        "${pkgs.alacritty}/Applications/Alacritty.app"
        "/System/Applications/Utilities/Activity Monitor.app"
        "/Applications/LibreWolf.app"
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
      "cursor"
      "parallels"
      "minecraft"
      "steam"
      "visual-studio-code"
      "nordvpn"
      "vlc"
      "cryptomator"
      {
        name = "librewolf";
        args = {
          no_quarantine = true;
        };
      }
    ];
  };
}
