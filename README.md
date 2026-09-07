## MacOS

### Install Nix package manager

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Select "no" to use NixOS, then "yes" to proceed.

Restart the shell.

### First time install

```sh
nix run nix-darwin -- switch --flake .#<host>
```

### Switch

```sh
sudo darwin-rebuild switch --flake .#mbp
sudo darwin-rebuild switch --flake .#squash
```

### Hosts

- `mbp` — primary interactive workstation (GUI apps, Homebrew). See `hosts/mbp/README.md`.
- `squash` — headless remote build host (no GUI, no Homebrew). See `hosts/squash/README.md`.

Settings shared by every host live in `hosts/common.nix` (nix-darwin) and
`home/common.nix` (home-manager); GUI-only extras live in `home/workstation.nix`.

### Linux Builder

See `hosts/LINUX_BUILDER.md`.