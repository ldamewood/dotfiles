# Jellyfin media server, running as a launchd system daemon.
#
# Data/config live under /var/lib/jellyfin; logs under /var/log/jellyfin.
# The server listens on port 8096 (HTTP) and 8920 (HTTPS) by default.
# Runs as the squash user (nix-darwin does not provision arbitrary system users).
#
# First-run setup: after `darwin-rebuild switch`, open
#   http://<squash-ip>:8096
# in a browser and complete the web wizard (create admin account, add
# libraries, etc.).  No further config is needed here — Jellyfin stores
# everything under its datadir.
#
# Useful commands:
#   sudo launchctl list | grep jellyfin                        # check status
#   sudo launchctl kickstart -k system/org.jellyfin.server     # restart
#   tail -f /var/log/jellyfin/jellyfin.log
{ pkgs, config, ... }:
let
  dataDir   = "/var/lib/jellyfin";
  cacheDir  = "/var/cache/jellyfin";
  logDir    = "/var/log/jellyfin";
  configDir = "/var/lib/jellyfin/config";
  user      = config.hostSettings.username;
in
{
  # Create required directories before the daemon starts
  system.activationScripts.jellyfinDirs = {
    text = ''
      for d in ${dataDir} ${cacheDir} ${logDir} ${configDir}; do
        mkdir -p "$d"
        chown ${user} "$d"
        chmod 750 "$d"
      done
    '';
    deps = [ "users" ];
  };

  launchd.daemons.jellyfin = {
    serviceConfig = {
      Label = "org.jellyfin.server";
      ProgramArguments = [
        "${pkgs.jellyfin}/bin/jellyfin"
        "--datadir"    dataDir
        "--configdir"  configDir
        "--cachedir"   cacheDir
        "--logdir"     logDir
      ];
      UserName = user;
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath    = "${logDir}/jellyfin.log";
      StandardErrorPath  = "${logDir}/jellyfin-error.log";
      SoftResourceLimits.NumberOfFiles = 65536;
    };
  };
}
