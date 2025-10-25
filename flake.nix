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
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages."${system}";
      linuxSystem = builtins.replaceStrings [ "darwin" ] [ "linux" ] system;
    in
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
          {
            nix.distributedBuilds = true;
            nix.buildMachines = [{
              hostName = "linux-builder";
              sshUser = "builder";
              sshKey = "/etc/nix/builder_ed25519";
              system = linuxSystem;
              maxJobs = 4;
              supportedFeatures = [ "kvm" "benchmark" "big-parallel" ];
            }];
            # launchd.daemons.linux-builder = {
            #   command = "${pkgs.darwin.linux-builder}/bin/create-builder";
            #   serviceConfig = {
            #     KeepAlive = true;
            #     RunAtLoad = true;
            #     StandardOutPath = "/var/log/darwin-builder.log";
            #     StandardErrorPath = "/var/log/darwin-builder.log";
            #     WorkingDirectory = "/var/lib/darwin-builder";
            #   };
            # };
          }
        ];
      };
    };
}
