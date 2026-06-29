{
  lib,
  config,
  ...
}:
with lib;
{
  config = mkIf config.my.home.hyprland.enable {
    wayland.windowManager.hyprland.settings = {
      window_rule =
        map
          (x: {
            name = "float-${x}";
            match.class = x;
            float = true;
            size = "(monitor_w*0.7) (monitor_h*0.7)";
            move = "(monitor_w*0.15) (monitor_h*0.1)";
          })
          [
            "Bitwarden"
            ".*-nngceckbapebfimnlniiiahkandclblb-.*" # bitwarden browser ext
            "xdg-desktop-portal-gtk"
          ];
    };
  };
}
