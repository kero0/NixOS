{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  mod = "SUPER";
  terminal = "${config.programs.kitty.package}/bin/kitty";
  fileManager = "${pkgs.nautilus}/bin/nautilus";
  menu = "${config.programs.rofi.finalPackage}/bin/rofi -show-icons -show drun -sidebar-mode";
  exec = cmd: ''hl.dsp.exec_cmd("${cmd}")'';
in
{
  config = mkIf config.my.home.hyprland.enable {
    wayland.windowManager.hyprland.settings = {
      mod._var = "SUPER";
      gesture = [
        {
          _args = [
            {
              fingers = 3;
              direction = "horizontal";
              action = "workspace";
            }
          ];
        }
      ];
      bind =
        lib.mapAttrsToList
          (k: v: {
            _args = [
              k
              (mkLuaInline v)
            ];
          })
          {
            "XF86AudioPlay" = exec "playerctl play-pause";
            "XF86AudioNext" = exec "playerctl next";
            "XF86AudioPrev" = exec "playerctl previous";
            "Print" =
              exec "grim - | tee ~/Pictures/$(date '+%Y-%m-%d-%T')-screenshot.png | wl-copy --type image/png";
            "XF86AudioRaiseVolume" = exec "swayosd-client --output-volume +5";
            "XF86AudioLowerVolume" = exec "swayosd-client --output-volume -5";
            "XF86AudioMute" = exec "swayosd-client --output-volume mute-toggle";
            "XF86AudioMicMute" = exec "swayosd-client --input-volume mute-toggle";
            "XF86MonBrightnessUp" = exec "swayosd-client --brightness +5";
            "XF86MonBrightnessDown" = exec "swayosd-client --brightness -5";
            "CAPS" = exec "swayosd-client --caps-lock";
            "${mod} + SHIFT + Q" = "hl.dsp.window.close()";
            "${mod} + SHIFT + C" = exec "${pkgs.wlogout}/bin/wlogout";
            "${mod}         + t" = ''
              function()
                  local win = hl.get_active_window()

                  if win.floating then
                      hl.dispatch(hl.dsp.window.float()) -- toggle floating off
                  else
                      hl.dispatch(hl.dsp.window.float()) -- toggle floating on

                      local monitor = hl.get_active_monitor()

                      hl.dispatch(hl.dsp.window.resize({
                          x = monitor.width * 0.8,
                          y = monitor.height * 0.85,
                          relative = false,
                      }))
                      hl.dispatch(hl.dsp.window.center())
                  end
              end
            '';
            "${mod}         + f" = ''hl.dsp.window.fullscreen({mode = "fullscreen", action = toggle})'';
            "${mod} + SHIFT + N" = exec "swaync-client -t -sw";
            "${mod} + SHIFT + Return" = exec "${fileManager}";
            "${mod} + CTRL  + Return" = exec "${terminal}";
            "${mod}         + s" = exec menu;
            "${mod} + CTRL  + b" = exec "pypr toggle bluetooth";
            "${mod} + CTRL  + v" = exec "pypr toggle volume";
            "${mod}         + Return" = exec "pypr toggle term";

            "${mod} +       + k" = ''hl.dsp.layout("focus l")'';
            "${mod} +       + j" = ''hl.dsp.layout("focus r")'';

            "${mod} + CTRL  + k" = ''hl.dsp.layout("+conf")'';
            "${mod} + CTRL  + j" = ''hl.dsp.layout("-conf")'';

            "${mod} + SHIFT + k" = ''hl.dsp.layout("swapcol l")'';
            "${mod} + SHIFT + j" = ''hl.dsp.layout("swapcol r")'';
            # "${mod} + SHIFT + :" = ''hl.dsp.layout("promote")'';
          }
        ++ [
          {
            _args = [
              "${mod} +       + mouse:272"
              (mkLuaInline "hl.dsp.window.drag()")
              { mouse = true; }
            ];
          }
          {
            _args = [
              "${mod} + SHIFT + mouse:272"
              (mkLuaInline "hl.dsp.window.resize()")
              { mouse = true; }
            ];
          }
          {
            _args = [
              "${mod} +       + mouse:273"
              (mkLuaInline "hl.dsp.window.resize()")
              { mouse = true; }
            ];
          }
        ]
        ++ (builtins.concatLists (
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
              {
                _args = [
                  "${mod} +       + ${ws}"
                  (mkLuaInline "hl.dsp.focus({ workspace = ${toString (x + 1)} })")
                ];
              }
              {
                _args = [
                  "${mod} + SHIFT + ${ws}"
                  (mkLuaInline "hl.dsp.window.move({ workspace = ${toString (x + 1)} })")
                ];
              }
            ]
          ) 10
        ));
    };
  };
}
