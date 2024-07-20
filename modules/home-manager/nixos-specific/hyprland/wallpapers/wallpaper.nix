{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.hyprland.wallpaper;
  wallpaperRandomizer = pkgs.writeShellScript "wallpaperRandomizer" ''
    set -euo pipefail
    monitors=$(hyprctl monitors | awk '/Monitor/ {print $2}')
    wallpaper="$(
      find ${config.xdg.configHome}/wallpapers -regextype posix-extended -regex '.*.(jpg|jpeg|png)$' |\
      shuf | head -n1
    )"

    hyprctl hyprpaper preload "$wallpaper"

    for monitor in $monitors; do
      hyprctl hyprpaper wallpaper "$monitor,$wallpaper"
    done
  '';
in
{
  options.my.home.hyprland.wallpaper = {
    enable = mkEnableOption "My wallpapers";
  };
  config = mkIf cfg.enable {
    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;
      };
    };
    systemd.user = {
      services.wallpaperRandomizer = {
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };

        Unit = {
          Description = "Set random desktop background using hyprpaper";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          Type = "oneshot";
          ExecStart = "${wallpaperRandomizer}";
          IOSchedulingClass = "idle";
        };
      };

      timers.wallpaperRandomizer = {
        Unit = {
          Description = "Set random desktop background using hyprpaper on an interval";
        };

        Timer = {
          OnUnitActiveSec = "1h";
        };

        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };
  };
}
