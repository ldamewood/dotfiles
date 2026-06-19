# MacBook Pro Configuration

This directory contains the NixOS configuration for the MacBook Pro.

## Linux Builder Management

The linux-builder is a NixOS VM that runs on macOS to build Linux packages (aarch64-linux and x86_64-linux via emulation).

**Note:** The builder is configured as **ephemeral**, meaning its filesystem is wiped on every *clean* restart. If you kill the QEMU process instead of shutting down the VM, the disk image may not be cleared—see "Rebooting when you can't login" for how to remove the disk so the next start is fresh.

### Starting the Linux Builder

To start the linux-builder VM:

```sh
nix run nixpkgs#darwin.linux-builder
```

This will prompt for your sudo password to install SSH credentials, then automatically log you in as the `builder` user.

**Troubleshooting:** If you see `Could not set up host forwarding rule 'tcp::31022-:22'`:
- Port 31022 may be in use: `lsof -i :31022`, then `kill -9 <PID>` (or `pkill -9 -f "qemu.*linux-builder"`). If nothing shows, try starting the builder again.
- If the port stays stuck, use another host port: in `linux-builder.nix` set `virtualisation.darwin-builder.hostPort = 31023;` and in `configuration.nix` set SSH `Port 31023` for `linux-builder`, then rebuild and restart the VM.

### Stopping the Linux Builder

The linux-builder runs as a QEMU process in the background. You can stop it in several ways:

**Method 1: Graceful shutdown via SSH (recommended)**

SSH into the VM and shut it down gracefully:

```sh
ssh linux-builder "sudo shutdown now"
```

**Method 2: Kill the QEMU process**

If SSH isn't available or the VM is unresponsive, find and kill the QEMU process. **Note:** Killing the process does not clear the VM disk; with ephemeral mode the disk is only discarded on clean shutdown. To get a fresh disk after killing, you must delete the disk image (see "Rebooting when you can't login").

```sh
# Find the QEMU process for linux-builder
ps aux | grep -i qemu | grep linux-builder

# Or find it by port (linux-builder uses port 31022)
lsof -i :31022

# Kill the process (replace PID with the actual process ID)
kill <PID>

# If it doesn't respond, force kill
kill -9 <PID>
```

You can also kill all QEMU processes (be careful if you have other VMs running):

```sh
pkill -f "qemu.*linux-builder"
# Or force kill
pkill -9 -f "qemu.*linux-builder"
```

### Rebooting when you can't login (e.g. disk full)

When the VM disk is full or SSH hangs, you can't run `shutdown` inside the VM. Reboot from the **host (macOS)** instead.

**Important:** Killing the QEMU process does *not* clear the disk image. With ephemeral mode, the disk is only discarded on clean VM shutdown. So after killing the process you must **delete the VM disk image** so the next start gets a fresh disk and the full-disk state is cleared.

1. **Kill the QEMU process** (from your Mac terminal):
   ```sh
   pkill -9 -f "qemu.*linux-builder"
   ```
   Or find the PID and kill it:
   ```sh
   lsof -i :31022   # find PID listening on linux-builder port
   kill -9 <PID>
   ```

2. **Find and remove the VM disk image** so the next start uses a fresh disk:
   - The disk is often in the directory where you ran `nix run nixpkgs#darwin.linux-builder` (e.g. `./nixos.qcow2` or `./Nix store image`). Check there first.
   - Or, *before* killing, find the disk path from the QEMU process:
     ```sh
     lsof -p $(pgrep -f 'qemu.*linux-builder') 2>/dev/null | grep -E 'qcow2|nix store'
     ```
     After killing, delete that file (e.g. `rm -f /path/to/nixos.qcow2`).
   - Common locations: current directory, `~/nixos.qcow2`, or a path under the Nix store that was printed when the VM was created ("Creating Nix store image...").

3. **Wait a few seconds**, then start the VM again:
   ```sh
   nix run nixpkgs#darwin.linux-builder
   ```

### Restarting the Linux Builder

To restart the linux-builder without doing a full `darwin-rebuild switch`:

1. **Stop the VM** (choose one method):
   - Graceful shutdown: `ssh linux-builder "sudo shutdown now"`
   - Kill QEMU process: `pkill -f "qemu.*linux-builder"` (or find PID with `ps aux | grep qemu` and `kill <PID>`)

2. **Wait a few seconds** for the process to fully terminate

3. **Start the VM again**:
   ```sh
   nix run nixpkgs#darwin.linux-builder
   ```

**Note:** With ephemeral mode enabled, configuration changes (and a fresh disk) take effect on the next VM start *after* a clean shutdown. If you stopped the VM by killing the QEMU process, delete the VM disk image (see "Rebooting when you can't login") so the next start gets a fresh disk. The builder starts automatically when you run `darwin-rebuild switch`, but you can restart it manually using the commands above without rebuilding.

**Restarting the Nix daemon** (only needed after SSH config changes):
```sh
sudo launchctl kickstart -k system/org.nixos.nix-daemon
```

### Clearing the Linux Builder Cache

SSH to the builder requires sudo. To clean the Nix store on the linux-builder (free disk space) without restarting the VM:

**From your Mac (remote):**
```sh
ssh linux-builder "sudo nix-collect-garbage -d"
```

**If you're already on the builder** (after `ssh linux-builder` and `sudo -i` or `sudo su`):
```sh
# Delete old generations and run GC (frees the most space)
sudo nix-collect-garbage -d

# Or: delete generations older than 7 days, then GC
sudo nix-collect-garbage --delete-older-than 7d

# GC only (removes store paths not referenced by any root)
sudo nix-store --gc
```

**Preview what would be removed** (no deletion):
```sh
sudo nix-store --gc --print-dead
```

The linux-builder is configured with automatic garbage collection that triggers when disk space is low (see `linux-builder.nix` for details). With ephemeral mode enabled, restarting the VM (and deleting the disk image if you killed QEMU) gives a complete clean slate.

### SSH Access

The linux-builder is accessible via SSH at `linux-builder` (configured in `configuration.nix`). SSH to the builder requires sudo (e.g. run commands with `sudo` on the builder, or remotely: `ssh linux-builder "sudo ..."`).

```sh
ssh linux-builder
```

Default port: `31022` (configured automatically)
