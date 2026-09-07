# mbp is the primary interactive workstation: full GUI apps, Homebrew casks,
# Dock/Finder tweaks. Shared settings come from ../common.nix and
# ../linux-builder.nix (see flake.nix).
{ pkgs, ... }:
{
  hostSettings.linuxBuilderIdentityAgent = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";

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
      "docker-desktop"
      "wezterm"
      "plex"
      "minecraft"
      "steam"
      "visual-studio-code"
      "nordvpn"
      "vlc"
      "cryptomator"
      "wifiman"
    ];
  };
}
