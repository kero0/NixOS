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
    services.swayosd.enable = true;

    wayland.windowManager.hyprland.settings.exec-once = with pkgs; [ ];
    systemd.user.services.wluma = mkIf (osConfig.hardware.sensor.iio.enable or false) {
      Unit = {
        Description = "Helper tool for Hyprland";
        PartOf = [ "hyprland-session.target" ];
        After = [ "hyprland-session.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.wluma}/bin/wluma";
        Restart = "always";
      };

      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };
  };
}
