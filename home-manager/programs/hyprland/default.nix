{ config, pkgs, lib, ... }:
let
  wsCommand = command: "${pkgs.writeShellScriptBin "hyprland-ws-${command}" /*bash */ ''
    shopt -s extglob
    ws="$(hyprctl workspaces -j |\
                  ${pkgs.jq}/bin/jq -r 'map(.name) | .[]' |\
                  ${config.programs.rofi.finalPackage}/bin/rofi -dmenu -mesg '<b>Select a workspace</b>')"
    case $ws in
    +([0-9])|special:*)
        x="$ws"
    ;;
    *[!0-9]*)
        x="special:$ws"
    ;;
    esac
    case $ws in
    special:*) command=${if command == "workspace" then "togglespecialworkspace" else command}
               x=''${x#${if command == "workspace" then "special:" else ""}}
    ;;
    *) command=${command} ;;
    esac
    hyprctl dispatch $command  $x
  ''}/bin/hyprland-ws-${command}";
in
{
  imports = [
    ./clipboard.nix
    ./lock
    ./notifications.nix
    ./pyprland.nix
  ];
  services.swayosd.enable = true;
  home.packages = with pkgs; [
    grim
    playerctl
    swaynotificationcenter
    wdisplays
    wl-clipboard
  ];
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
      "$fileManager" = "${pkgs.gnome.nautilus}/bin/nautilus";
      "$menu" = "${config.programs.rofi.finalPackage}/bin/rofi -show-icons -show drun -sidebar-mode";
      "$movetoWS" = wsCommand "movetoworkspace";
      "$gotoWS" = wsCommand "workspace";

      exec-once = [ ];

      monitor = ",preferred,auto,auto";
      misc.force_default_wallpaper = -1;
      gestures.workspace_swipe = true;
      master.new_is_master = false;
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
        drop_shadow = false;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };
      general = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        gaps_in = 5;
        gaps_out = 10;
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
        touchpad = { natural_scroll = true; };
        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
      };
      env = [
        # Some default env vars.
        "XCURSOR_SIZE,24"
        "QT_QPA_PLATFORMTHEME,qt5ct" # change to qt6ct if you have that
      ];


      bind = import ./bindings.nix;
      bindel = [
        ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume 5"
        ", XF86AudioLowerVolume, exec, swayosd-client --output-volume -5"
        ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
        ", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"

        ", XF86MonBrightnessUp, exec, swayosd-client --brightness 5"
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
}
