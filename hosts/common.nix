# nix-darwin settings shared by every host, headless or not.
{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.hostSettings;
in
{
  options.hostSettings.username = lib.mkOption {
    type = lib.types.str;
    default = "liam";
    description = "Primary macOS user account for this host.";
  };

  config = {
    # Allow 1Password CLI and browser extension (NUR addon name can include version)
    nixpkgs.config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "1password-cli"
        "1password-x-password-manager"
        "claude-code"
      ]
      || lib.hasPrefix "onepassword-password-manager" (lib.getName pkg);

    environment.systemPackages = [
      pkgs.vim
    ];

    users.users.${cfg.username} = {
      home = "/Users/${cfg.username}";
    };

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        cfg.username
      ];
      system-features = [
        "nixos-test"
        "apple-virt"
      ];
    };

    programs.zsh.enable = true;

    system.stateVersion = 5;

    nixpkgs.hostPlatform = "aarch64-darwin";

    system.primaryUser = cfg.username;
  };
}
