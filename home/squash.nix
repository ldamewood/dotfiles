# squash is a headless remote build host: just the shared baseline, no
# GUI-only extras from ./workstation.nix.
{
  imports = [
    ./common.nix
  ];
}
