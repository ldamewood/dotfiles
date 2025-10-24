{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    dotDir = ".config/zsh";
    shellAliases = {
      ll = "ls -l";
      ta = "tmux attach";
      n = "nvim .";
      k = "kubectl";
      tmux-left = "tmux set-option status-left-length 40";
    };
    initContent = ''
      eval "$(zoxide init zsh)"

      # aws cli auto complete
      complete -C '${pkgs.awscli}/bin/aws_completer' aws

      DISABLE_AUTO_TITLE="true"
    '';
  };
}

