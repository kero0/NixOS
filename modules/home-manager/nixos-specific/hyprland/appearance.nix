{
  lib,
  config,
  ...
}:
with lib;
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
          column_width = 0.5;
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
