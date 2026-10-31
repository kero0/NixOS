{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.home.theme.cursor;
in
{
  options.my.home.theme.cursor.enable = mkEnableOption "Cursor theme";
  config = mkIf cfg.enable {
    home.pointerCursor = {
      enable = true;
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 32;
      gtk.enable = true;
    };
  };
}
