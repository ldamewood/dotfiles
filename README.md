## MacOS

### Install Nix package manager

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Select "no" to use NixOS, then "yes" to proceed.

Restart the shell.

### First time install

```sh
nix run nix-darwin -- switch --flake .
```

### Switch

```sh
sudo darwin-rebuild switch --flake .#mbp
```
