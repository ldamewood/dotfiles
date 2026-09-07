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

  # Wrapper that creates required directories then execs Jellyfin.
  # Keeps the launchd plist simple and avoids ordering issues with
  # activationScripts.
  startScript = pkgs.writeShellScript "jellyfin-start" ''
    mkdir -p ${dataDir} ${configDir} ${cacheDir} ${logDir}
    exec ${pkgs.jellyfin}/bin/jellyfin \
      --datadir   ${dataDir}   \
      --configdir ${configDir} \
      --cachedir  ${cacheDir}  \
      --logdir    ${logDir}
  '';
in
{
  launchd.daemons.jellyfin = {
    serviceConfig = {
      Label = "org.jellyfin.server";
      ProgramArguments = [ "${startScript}" ];
      UserName = user;
      RunAtLoad = true;
      KeepAlive = true;
      SoftResourceLimits.NumberOfFiles = 65536;
    };
  };
}
