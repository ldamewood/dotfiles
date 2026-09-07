{
  description = "liam's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    _1password-shell-plugins.url = "github:1Password/shell-plugins";

    # Firefox/Librewolf extensions (e.g. 1Password)
    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "aarch64-darwin";
      lib = nixpkgs.lib;
      # Use nixpkgs with allowUnfree for 1Password addon; NUR is evaluated in flake so needs this here
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg:
          builtins.elem (lib.getName pkg) [ "1password-cli" "1password-x-password-manager" "claude-code" ]
          || lib.hasPrefix "onepassword-password-manager" (lib.getName pkg);
      };
      linuxSystem = builtins.replaceStrings [ "darwin" ] [ "linux" ] system;
      # Builder NUR expects; nixpkgs doesn't expose it, so we define it (same as NUR's buildFirefoxXpiAddon)
      buildMozillaXpiAddon = pkgs.lib.makeOverridable (
        { pname, version, addonId, url ? "", urls ? [ ], sha256, meta, ... }:
        pkgs.stdenv.mkDerivation {
          name = "${pname}-${version}";
          inherit meta;
          src = pkgs.fetchurl { inherit url urls sha256; };
          preferLocalBuild = true;
          allowSubstitutes = true;
          passthru = { inherit addonId; };
          buildCommand = ''
            dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
            mkdir -p "$dst"
            install -v -m644 "$src" "$dst/${addonId}.xpi"
          '';
        }
      );
      # NUR firefox-addons; pass to home-manager
      firefox-addons-pkgs = import (inputs.firefox-addons + "/default.nix") {
        inherit buildMozillaXpiAddon;
        fetchurl = pkgs.fetchurl;
        lib = pkgs.lib;
        stdenv = pkgs.stdenv;
      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild switch --flake .#mbp
      darwinConfigurations."mbp" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/common.nix
          ./hosts/linux-builder.nix
          ./hosts/mbp/configuration.nix
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit firefox-addons-pkgs; };
            home-manager.users.liam = {
              imports = [
                inputs._1password-shell-plugins.hmModules.default
                ./home/mbp.nix
              ];
            };
          }
        ];
      };

      # Headless remote build host. Build using:
      # $ darwin-rebuild switch --flake .#squash
      darwinConfigurations."squash" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/common.nix
          ./hosts/linux-builder.nix
          ./hosts/squash/configuration.nix
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager.backupFileExtension = "backup";
            home-manager.users.squash = {
              imports = [ ./home/squash.nix ];
            };
          }
        ];
      };
    };
}
