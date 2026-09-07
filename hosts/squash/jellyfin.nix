# Jellyfin media server, running as a launchd system daemon.
#
# Data/config live under ~/Library/Application Support/Jellyfin.
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
#   tail -f ~/Library/Logs/Jellyfin/jellyfin.log
{ pkgs, config, ... }:
let
  user      = config.hostSettings.username;
  home      = "/Users/${user}";
  dataDir   = "${home}/Library/Application Support/Jellyfin/Data";
  configDir = "${home}/Library/Application Support/Jellyfin/Config";
  cacheDir  = "${home}/Library/Caches/Jellyfin";
  logDir    = "${home}/Library/Logs/Jellyfin";

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
