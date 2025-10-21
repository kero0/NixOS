{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.hyprland;
  wallpaper-randomizer = pkgs.writeShellScript "wallpaper-randomizer" ''
    #!/usr/bin/env bash
    set -eux
    set -o pipefail
    hyprctl=${config.wayland.windowManager.hyprland.package}/bin/hyprctl
    while true; do
        WALLPAPER=$(find ${config.xdg.configHome}/wallpapers -regextype posix-extended -regex '.*\.(jpe?g|png)$' |\
        shuf | head -n1
        )
        $hyprctl hyprpaper preload "$WALLPAPER"
        $hyprctl hyprpaper reload ,"$WALLPAPER"
        sleep 1h
    done
  '';
in
{
  options.my.home.hyprland.enable = mkEnableOption "Enable hyprland window manager";
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      grim
      playerctl
      swaynotificationcenter
      wdisplays
      wl-clipboard
    ];
    services = {
      hyprpaper = {
        enable = true;
        settings = {
          ipc = "on";
        };
      };
      hyprpolkitagent.enable = true;
    };

    wayland.windowManager.hyprland = {
      enable = true;
      systemd = {
        enable = true;
        variables = [ "--all" ];
      };
      xwayland.enable = true;
      settings = {
        exec = [ "${wallpaper-randomizer}" ];

        monitor = ",preferred,auto,auto";
        master.new_status = "master";
        misc = {
          force_default_wallpaper = -1;
          disable_hyprland_logo = true;
          enable_swallow = true;
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
        input = {
          kb_layout = "us";
          follow_mouse = 1;
          touchpad = {
            natural_scroll = true;
          };
          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        };
        env = [
          "XCURSOR_SIZE,24"
          "QT_QPA_PLATFORMTHEME,qt5ct"
          "ELECTRON_OZONE_PLATFORM_HINT,wayland"
          "NIXOS_OZONE_WL,1"
        ];
      };
    };
  };
}
