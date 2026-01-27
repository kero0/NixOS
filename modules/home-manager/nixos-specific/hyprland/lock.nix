{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.hyprland.lock;
in
{
  options.my.home.hyprland.lock.enable = mkEnableOption "Enable screen lock";
  config = mkIf cfg.enable {
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          grace = 5;
          ignore_empty_input = true;
        };
      };
    };
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = "false";
        };
        listener = [
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }

          {
            timeout = 380;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }

          {
            timeout = 1800;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}
