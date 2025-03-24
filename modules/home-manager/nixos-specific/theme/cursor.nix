{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.theme.cursor;
in
{
  options.my.home.theme.cursor.enable = mkEnableOption "Cursor theme";
  config = mkIf cfg.enable {
    home.pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 32;
      gtk.enable = true;
    };
  };
}
