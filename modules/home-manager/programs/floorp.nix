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
      enableGnomeExtensions = osConfig.services.gnome.gnome-browser-connector.enable or true;
      package = pkgs.floorp.override {
        nativeMessagingHosts = [
          pkgs.gnome-browser-connector
          pkgs.tridactyl-native
        ];
      };
      profiles = {
        default = {
          id = 0;
        };
      };
    };
  };
}
