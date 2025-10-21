{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
{
  config = mkIf config.my.home.hyprland.enable {
    wayland.windowManager.hyprland.settings = {
      windowrule = map (x: "float, pin, size 35% 35%, move 30% 20%, ${x}") [
        "class:Bitwarden"
        "class:.*-nngceckbapebfimnlniiiahkandclblb-.*" # bitwarden browser ext
        "class:xdg-desktop-portal-gtk"
      ];
    };
  };
}
