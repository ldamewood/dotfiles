# squash is a headless remote Mac: no GUI apps, no Homebrew, no Dock/Finder
# settings. It exists to run claude/git/zsh over SSH and to act as an
# aarch64-linux builder. Shared settings come from ../common.nix and
# ../linux-builder.nix (see flake.nix).
{ ... }:
{
  hostSettings.username = "squash";

  # No 1Password desktop app here, so no agent socket to hand the
  # linux-builder ssh stanza — leave hostSettings.linuxBuilderIdentityAgent
  # at its default (null) and rely on the default SSH agent / identity files.
}
