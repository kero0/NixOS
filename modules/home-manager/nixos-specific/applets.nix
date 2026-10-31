{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.home.applets;
in
{
  options.my.home.applets.enable = mkEnableOption "Enable applets config";
  config = mkIf cfg.enable {
    services = {
      network-manager-applet.enable = true;
      blueman-applet.enable = true;
      udiskie = {
        enable = true;
        notify = true;
      };
    };
  };
}
