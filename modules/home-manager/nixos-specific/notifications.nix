{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.notification-manager;
in
{
  options.my.home.notification-manager.enable = mkEnableOption "Enable notification manager/center";
  config = mkIf cfg.enable {
    systemd.user.services.swaync = {
      Unit = {
        Description = "Notification center";
        PartOf = [ "wayland-session.target" ];
        After = [ "wayland-session.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.swaynotificationcenter}/bin/swaync";
        Restart = "always";
      };

      Install = {
        WantedBy = [ "wayland-session.target" ];
      };
    };
  };
}
