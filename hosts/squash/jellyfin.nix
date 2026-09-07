# Jellyfin media server, running as a launchd system daemon.
#
# Data/config live under /var/lib/jellyfin; logs under /var/log/jellyfin.
# The server listens on port 8096 (HTTP) and 8920 (HTTPS) by default.
#
# First-run setup: after `darwin-rebuild switch`, open
#   http://<squash-ip>:8096
# in a browser and complete the web wizard (create admin account, add
# libraries, etc.).  No further config is needed here — Jellyfin stores
# everything under its datadir.
#
# Useful commands:
#   sudo launchctl list | grep jellyfin   # check service status
#   sudo launchctl kickstart -k system/org.jellyfin.server  # restart
#   tail -f /var/log/jellyfin/jellyfin.log
{ pkgs, ... }:
let
  dataDir = "/var/lib/jellyfin";
  cacheDir = "/var/cache/jellyfin";
  logDir = "/var/log/jellyfin";
  configDir = "/var/lib/jellyfin/config";
  user = "jellyfin";
  group = "jellyfin";
in
{
  # Create the jellyfin system user/group
  users.users.${user} = {
    uid = 300;
    gid = 300;
    home = dataDir;
    shell = "/usr/bin/false";
    description = "Jellyfin media server";
  };
  users.groups.${group}.gid = 300;

  # Create required directories before the daemon starts
  system.activationScripts.jellyfinDirs = {
    text = ''
      for d in ${dataDir} ${cacheDir} ${logDir} ${configDir}; do
        mkdir -p "$d"
        chown ${user}:${group} "$d"
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
        "--datadir"
        dataDir
        "--configdir"
        configDir
        "--cachedir"
        cacheDir
        "--logdir"
        logDir
      ];
      UserName = user;
      GroupName = group;
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "${logDir}/jellyfin.log";
      StandardErrorPath = "${logDir}/jellyfin-error.log";
      SoftResourceLimits.NumberOfFiles = 65536;
    };
  };

  # Open the HTTP port in the macOS firewall (if pf/alf is active)
  # and make the port visible in the host's service inventory.
  networking.firewall.allowedTCPPorts = [ 8096 8920 ];
}
