{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.hyprland.binds;

  togglefloat = pkgs.writeShellScriptBin "togglefloat" ''
    floating=$(hyprctl activewindow -j | jq .floating)
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
    "${
      pkgs.writeShellScriptBin "hyprland-ws-${command}"
        # bash
        ''
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
        ''
    }/bin/hyprland-ws-${command}";
in
{
  options.my.home.hyprland.binds.enable = mkEnableOption "Enable hyprland default bindings";
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      "$movetoWS" = wsCommand "movetoworkspacesilent";
      "$gotoWS" = wsCommand "focusworkspaceoncurrentmonitor";
      # repeatable bindings
      binde = [
        # resize window
        "$mod CTRL  , l, resizeactive, 10 0"
        "$mod CTRL  , h, resizeactive, -10 0"
        "$mod CTRL  , k, resizeactive, 0 -10"
        "$mod CTRL  , j, resizeactive, 0 10"
      ];
      bind =
        [
          "$mod Shift , Q, killactive,"
          "$mod Shift , C, exec,${pkgs.wlogout}/bin/wlogout"
          "$mod       , t, exec, ${togglefloat}/bin/togglefloat"
          "$mod       , f, fullscreen,"
          "$mod       , p, pseudo, # dwindle"
          "$mod       , j, togglesplit, # dwindle"

          "$mod SHIFT , N,      exec, swaync-client -t -sw"
          "$mod SHIFT , Return, exec, $fileManager"
          "$mod CTRL  , Return, exec, $terminal"
          "$mod       , s,      exec, $menu"

          "$mod       , r,      togglespecialworkspace, ref"
          "$mod SHIFT , r,      movetoworkspacesilent, special:ref"
          "$mod CTRL  , b,      exec, pypr toggle bluetooth"
          "$mod CTRL  , v,      exec, pypr toggle volume"
          "$mod       , Return, exec, pypr toggle term"

          # move focus
          "$mod       , h, movefocus, l"
          "$mod       , l, movefocus, r"
          "$mod       , k, movefocus, u"
          "$mod       , j, movefocus, d"
          # move window
          "$mod SHIFT , H, movewindow, l"
          "$mod SHIFT , L, movewindow, r"
          "$mod SHIFT , K, movewindow, u"
          "$mod SHIFT , J, movewindow, d"

          "           , XF86AudioPlay, exec, playerctl play-pause"
          "           , XF86AudioNext, exec, playerctl next"
          "           , XF86AudioPrev, exec, playerctl previous"
          "           , Print, exec, grim - | tee ~/Pictures/$(date '+%Y-%m-%d-%T')-screenshot.png | wl-copy --type image/png"

          "$mod Shift , Tab, exec, $movetoWS"
          "$mod       , Tab, exec, $gotoWS"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          builtins.concatLists (
            builtins.genList (
              x:
              let
                ws =
                  let
                    c = (x + 1) / 10;
                  in
                  builtins.toString (x + 1 - (c * 10));
              in
              [
                "$mod       , ${ws}, focusworkspaceoncurrentmonitor , ${toString (x + 1)}"
                "$mod SHIFT , ${ws}, movetoworkspacesilent          , ${toString (x + 1)}"
              ]
            ) 10
          )
        );
    };
  };
}
