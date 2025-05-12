{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.clipboard-manager;
in
{
  options.my.home.clipboard-manager.enable = mkEnableOption "Enable clipboard-manager";
  config = mkIf cfg.enable {
    services.cliphist.enable = true;
    systemd.user.services = {
      wl-clip-persist = {
        Unit = {
          Description = "Persist clipboard when application exits";
          PartOf = [ "hyprland-session.target" ];
          After = [ "hyprland-session.target" ];
          ConditionEnvironment = "WAYLAND_DISPLAY";
        };

        Service = {
          Type = "simple";
          ExecStart = "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard both";
          Restart = "always";
        };

        Install = {
          WantedBy = [ "hyprland-session.target" ];
        };
      };
    };

    wayland.windowManager.hyprland.settings = {
      "$cliphist-rofi-img" = "${pkgs.cliphist-rofi-img}/bin/cliphist-rofi-img";
      bind = [
        "$mod SHIFT , V,      exec, rofi -modi clipboard:$cliphist-rofi-img -show clipboard -show-icons"
      ];
    };
  };
}
