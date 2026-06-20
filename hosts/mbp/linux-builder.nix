{ pkgs, lib, ... }:

{
  # Manages the linux-builder VM for aarch64-linux builds
  nix.linux-builder = {
    enable = true;
    maxJobs = 16;
    ephemeral = true;
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
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
}

