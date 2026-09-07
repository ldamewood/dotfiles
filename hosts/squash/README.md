# squash Configuration

Headless remote macOS machine (Apple Silicon). No GUI apps and no Homebrew —
everything is provided by nix/home-manager: `claude`, `git`, `zsh`, and the
rest of the shared CLI baseline in `../../home/common.nix`.

It also runs the shared linux-builder VM (`../linux-builder.nix`) to act as
an aarch64-linux build host — see [`../LINUX_BUILDER.md`](../LINUX_BUILDER.md)
for VM management commands (starting/stopping/clearing the cache).

## First time install

```sh
nix run nix-darwin -- switch --flake .#squash
```

## Switch

```sh
sudo darwin-rebuild switch --flake .#squash
```

## SSH / git auth

There's no 1Password desktop app on this host, so `hostSettings.linuxBuilderIdentityAgent`
is left unset in `configuration.nix` and git/SSH auth uses a plain local SSH
key under `~/.ssh` — add one manually after first boot.
