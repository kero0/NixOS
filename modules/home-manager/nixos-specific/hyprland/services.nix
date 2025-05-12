{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
with lib;
let
  cfg = config.my.home.hyprland;
in
{
  config = mkIf cfg.enable {
    services = {
      network-manager-applet.enable = true;
      swayosd.enable = true;
      wluma = mkIf (osConfig.hardware.sensor.iio.enable or true) {
        enable = true;
        settings = {
          als.iio = {
            path = "";
            thresholds = {
              "0" = "night";
              "20" = "dark";
              "80" = "dim";
              "250" = "normal";
              "500" = "bright";
              "800" = "outdoors";
            };
          };
        };
      };
    };
  };
}
