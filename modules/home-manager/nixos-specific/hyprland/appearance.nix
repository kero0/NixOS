{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.my.home.hyprland.enable {
    wayland.windowManager.hyprland.settings.config = [
      {
        general = {
          gaps_in = 2;
          gaps_out = 3;
          border_size = 2;
          layout = "scrolling";
          allow_tearing = false;
        };
      }
      {
        scrolling = {
          fullscreen_on_one_column = true;
          column_width = 1;
          explicit_column_widths = [
            0.33
            0.5
            0.67
            1.0
          ];
        };
      }
      {
        animations = {
          enabled = true;
        };
      }
      {
        decoration = {
          rounding = 10;
        };
      }
    ];
  };
}
