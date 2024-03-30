{ myuser, pkgs, homedir, ... }: {
  imports = [ ./dev-stuff ./email ./programs ];

  home.stateVersion = "22.05";

  home = {
    username = "${myuser}";
    homeDirectory = pkgs.lib.mkIf pkgs.stdenv.isLinux "${homedir}";
  };

  fonts.fontconfig.enable = true;

  programs.home-manager = {
    enable = true;
    path = homedir + /.config;
  };

  xdg.enable = true;
}
