{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
with lib;
let
  cfg = config.my.home.floorp;
in
{
  options.my.home.floorp.enable = mkEnableOption "Enable floorp";
  config = mkIf cfg.enable {
    programs.floorp = {
      enable = true;
      enableGnomeExtensions =
        osConfig.services.gnome.gnome-browser-connector.enable or (!pkgs.stdenv.isDarwin);
      package = pkgs.floorp.override {
        nativeMessagingHosts = [
          pkgs.tridactyl-native
        ] ++ lib.lists.optional config.programs.floorp.enableGnomeExtensions pkgs.gnome-browser-connector;
      };
      profiles = {
        default = {
          id = 0;
        };
      };
    };
  };
}
