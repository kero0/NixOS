{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
with lib;
let
  cfg = config.my.home;
in
{
  options.my.home = {
    username = mkOption {
      type = types.str;
      default = osConfig.my.user.username or (throw "Username unset");
    };

    homedir = mkOption {
      type = types.str;
      default = osConfig.my.user.homedir or (throw "Homedir unset");
    };
  };

  config = {
    home.stateVersion = "22.05";

    home = {
      inherit (cfg) username;
      homeDirectory = lib.mkIf pkgs.stdenv.isLinux cfg.homedir;
    };

    fonts.fontconfig.enable = true;

    programs.home-manager = {
      enable = true;
      path = lib.mkForce (cfg.homedir + "/.config");
    };
    xdg.enable = true;
  };
}
