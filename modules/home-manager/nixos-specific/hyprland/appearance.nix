{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  togglefloat = pkgs.writeShellScriptBin "togglefloat" ''
    floating=$(hyprctl activewindow -j | ${config.programs.jq.package}/bin/jq .floating)
    if [ $floating = "true" ]; then
        hyprctl dispatch togglefloating
    else
        hyprctl --batch					\
    	    dispatch togglefloating ';'			\
    	    dispatch resizeactive 'exact 80% 85%' ';'	\
    	    dispatch centerwindow
    fi
  '';
  wsCommand =
    command:
    "${pkgs.writeShellScriptBin "hyprland-ws-${command}" ''
      shopt -s extglob
      mapfile -t wss < <(hyprctl workspaces -j |\
                    ${config.programs.jq.package}/bin/jq -r 'map(.name) | .[]')
      ws="$(printf "%s\\n" "''${wss[@]}" |\
                    ${config.programs.rofi.finalPackage}/bin/rofi -dmenu -mesg '<b>Select a workspace</b>')"
      case $ws in
      special:*) command=${
        if command == "focusworkspaceoncurrentmonitor" then "togglespecialworkspace" else command
      }
                 x=''${ws#special:}
      ;;
      *) command=${command}
                 x=$ws
      ;;
      esac
      if grep -q "$ws" <(printf "%s\\n" "''${wss[@]}"); then
        hyprctl dispatch $command  $x
      else
        window="$(hyprctl activewindow -j | ${config.programs.jq.package}/bin/jq -r '.address')"
        hyprctl dispatch workspace 99
        hyprctl dispatch workspace emptynm
        hyprctl dispatch renameworkspace "$(hyprctl activeworkspace -j | ${config.programs.jq.package}/bin/jq '.id')" "$x"
        ${strings.optionalString (strings.hasInfix "move" command) ''hyprctl dispatch $command "$x,address:$window"''}
      fi
    ''}/bin/hyprland-ws-${command}";
in
{
  config = mkIf config.my.home.hyprland.enable {
    wayland.windowManager.hyprland.settings = {
      general = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        gaps_in = 2;
        gaps_out = 3;
        border_size = 2;
        "col.active_border" = "$accent";
        "col.inactive_border" = "$base";
        layout = "dwindle";
        # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false;
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
    };
  };
}
