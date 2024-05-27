{
  pkgs,
  config,
  osConfig,
  ...
}:
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

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;

      desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Pictures";
      publicShare = "${config.home.homeDirectory}/Public";
      templates = "${config.home.homeDirectory}/Templates";
      videos = "${config.home.homeDirectory}/Videos";
    };
  };
}
