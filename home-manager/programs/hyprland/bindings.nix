[
  "$mod Shift, Q, killactive,"
  "$mod Shift, Return, exec, $fileManager"
  "$mod, Return, exec, $terminal"
  "$mod, T, togglefloating,"
  "$mod, F, fullscreen,"
  "$mod, S, exec, $menu"
  "$mod, P, pseudo, # dwindle"
  "$mod, J, togglesplit, # dwindle"
  ", Print, exec, grimblast copy area"
  "$mod SHIFT, N, exec, swaync-client -t -sw"
  "$mod SHIFT, V, exec, rofi -modi clipboard:$cliphist-rofi-img -show clipboard -show-icons"

  # move focus
  "$mod, h, movefocus, l"
  "$mod, l, movefocus, r"
  "$mod, k, movefocus, u"
  "$mod, j, movefocus, d"
  # move window
  "$mod SHIFT, H, movewindow, l"
  "$mod SHIFT, L, movewindow, r"
  "$mod SHIFT, K, movewindow, u"
  "$mod SHIFT, J, movewindow, d"
  # resize window
  "$mod CTRL, l, resizeactive, 10 0"
  "$mod CTRL, h, resizeactive, -10 0"
  "$mod CTRL, k, resizeactive, 0 -10"
  "$mod CTRL, j, resizeactive, 0 10"

  ", XF86AudioPlay, exec, playerctl play-pause"
  ", XF86AudioNext, exec, playerctl next"
  ", XF86AudioPrev, exec, playerctl previous"
  ", Print, exec, grim ~/Pictures/$(date '+%Y-%m-%d-%T')-screenshot.png"
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
        "$mod, ${ws}, workspace, ${toString (x + 1)}"
        "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
      ]
    )
    10)
)
