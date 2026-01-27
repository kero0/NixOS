{
  lib,
  config,
  ...
}:
with lib;
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
