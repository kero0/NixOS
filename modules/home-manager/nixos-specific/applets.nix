{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.applets;
in
{
  options.my.home.applets.enable = mkEnableOption "Enable applets config";
  config = mkIf cfg.enable {
    services = pkgs.lib.mkIf pkgs.stdenv.isLinux {
      network-manager-applet.enable = true;
      blueman-applet.enable = true;
      udiskie = {
        enable = true;
        notify = true;
      };
    };
  };
}
