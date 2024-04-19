{ pkgs, osConfig, ... }:
{
  home.stateVersion = "22.05";

  home = {
    username = osConfig.my.user.username;
    homeDirectory = pkgs.lib.mkIf pkgs.stdenv.isLinux osConfig.my.user.homedir;
  };

  fonts.fontconfig.enable = true;

  programs.home-manager = {
    enable = true;
    path = osConfig.my.user.homedir + /.config;
  };

  xdg.enable = true;
}
