{ config, pkgs, ... }:

{
  programs.aerospace = {
    enable = pkgs.stdenv.isDarwin;
  };
}
