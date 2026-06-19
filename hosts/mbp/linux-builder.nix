{ pkgs, lib, ... }:

{
  # Configure the linux-builder with custom resources
  # This automatically manages the VM and sets up aarch64-linux building
  # Temporarily disabled to fix bootstrapping issues - set to true after fixing config
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

