{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    _1password-shell-plugins.url = "github:1Password/shell-plugins";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      ...
    }:

    {
      # Build darwin flake using:
      # $ darwin-rebuild switch --flake .#mbp
      darwinConfigurations."mbp" = nix-darwin.lib.darwinSystem {
        modules = [
          ./hosts/mbp/configuration.nix
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager.users.liam = {
              imports = [
                inputs._1password-shell-plugins.hmModules.default
                ./home/home.nix
              ];
            };
          }
        ];
      };
    };
}
