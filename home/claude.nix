{ pkgs, ... }:
{
  home.packages = [ pkgs.claude-code ];

  home.file.".claude/settings.json".text = builtins.toJSON {
    enabledPlugins = {
    };
  };

  programs.zsh.shellAliases.cc = "claude";
}
