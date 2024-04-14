[
  "$mod Shift , Q, killactive,"
  "$mod       , t, togglefloating,"
  "$mod       , f, fullscreen,"
  "$mod       , p, pseudo, # dwindle"
  "$mod       , J, togglesplit, # dwindle"

  "$mod SHIFT , N,      exec, swaync-client -t -sw"
  "$mod Shift , Return, exec, $fileManager"
  "$mod       , Return, exec, $terminal"
  "$mod       , s,      exec, $menu"

  "$mod       , r,      togglespecialworkspace, ref"
  "$mod SHIFT , r,      movetoworkspace, special:ref"
  "$mod CTRL  , v,      exec, pypr toggle volume"
  "$mod CTRL  , Return, exec, pypr toggle term"

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
  # resize window
  "$mod CTRL  , l, resizeactive, 10 0"
  "$mod CTRL  , h, resizeactive, -10 0"
  "$mod CTRL  , k, resizeactive, 0 -10"
  "$mod CTRL  , j, resizeactive, 0 10"

  "           , XF86AudioPlay, exec, playerctl play-pause"
  "           , XF86AudioNext, exec, playerctl next"
  "           , XF86AudioPrev, exec, playerctl previous"
  "           , Print, exec, grim ~/Pictures/$(date '+%Y-%m-%d-%T')-screenshot.png"

  "$mod Shift , Tab, exec, $movetoWS"
  "$mod       , Tab, exec, $gotoWS"
]
++ (
  # workspaces
  # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
  builtins.concatLists (builtins.genList
    (
      x:
      let
        ws =
          let
            c = (x + 1) / 10;
          in
          builtins.toString (x + 1 - (c * 10));
      in
      [
        "$mod       , ${ws}, workspace      , ${toString (x + 1)}"
        "$mod SHIFT , ${ws}, movetoworkspace, ${toString (x + 1)}"
      ]
    )
    10)
)
