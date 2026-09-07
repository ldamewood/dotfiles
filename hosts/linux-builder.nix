# Shared linux-builder VM, used by every host that should act as an
# aarch64-linux (and, via emulation, x86_64-linux) builder.
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
  options.hostSettings.linuxBuilderIdentityAgent = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = ''
      SSH agent socket to use for the `linux-builder` Host ssh stanza (e.g.
      1Password's agent socket). Leave null to fall back to the default
      agent (SSH_AUTH_SOCK / default identity files).
    '';
  };

  config = {
    # Manages the linux-builder VM for aarch64-linux builds
    nix.linux-builder = {
      enable = true;
      maxJobs = 16;
      ephemeral = true;
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      config = {
        # qemu-vm.nix disables timesyncd ("time comes from KVM"). On Darwin, QEMU
        # is not KVM; the guest RTC can be wildly wrong and HTTPS/substituters fail.
        services.timesyncd.enable = lib.mkForce true;

        virtualisation = {
          darwin-builder = {
            diskSize = 300 * 1024;
            memorySize = 32 * 1024;
          };
          cores = 6;
        };
      };
    };

    # SSH configuration for linux-builder
    programs.ssh.extraConfig = ''
      Host linux-builder
        Hostname localhost
        HostKeyAlias linux-builder
        Port 31022
        ${lib.optionalString (cfg.linuxBuilderIdentityAgent != null) ''
          IdentityAgent "${cfg.linuxBuilderIdentityAgent}"''}
    '';
  };
}
