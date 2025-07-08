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
        "$mod" = "SUPER";
        "$terminal" = "${config.programs.kitty.package}/bin/kitty";
        "$fileManager" = "${pkgs.nautilus}/bin/nautilus";
        "$menu" = "${config.programs.rofi.finalPackage}/bin/rofi -show-icons -show drun -sidebar-mode";

        exec = [ "${wallpaper-randomizer}" ];

        monitor = ",preferred,auto,auto";
        misc.force_default_wallpaper = -1;
        gestures.workspace_swipe = true;
        master.new_status = "master";
        misc = {
          enable_swallow = true;
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        animations = {
          enabled = true;
          # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };
        decoration = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          rounding = 10;
          blur = {
            enabled = false;
            size = 3;
            passes = 1;
            vibrancy = 0.1696;
          };
        };
        general = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          gaps_in = 2;
          gaps_out = 3;
          border_size = 2;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          layout = "dwindle";
          # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
          allow_tearing = false;
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
          # Some default env vars.
          "XCURSOR_SIZE,24"
          "QT_QPA_PLATFORMTHEME,qt5ct" # change to qt6ct if you have that
        ];

        bindel = [
          ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume +5"
          ", XF86AudioLowerVolume, exec, swayosd-client --output-volume -5"
          ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
          ", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"

          ", XF86MonBrightnessUp, exec, swayosd-client --brightness +5"
          ", XF86MonBrightnessDown, exec, swayosd-client --brightness -5"
          "CAPS, Caps_Lock, exec, swayosd-client --caps-lock"
        ];
        bindm = [
          # Move/resize windows with mainMod + LMB/RMB and dragging
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
      };
    };
  };
}
