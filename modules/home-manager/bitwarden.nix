{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.bitwarden;
in
{
  options.my.home.bitwarden = {
    enable = mkEnableOption "Enable bitwarden config";
    email = mkOption {
      type = types.str;
      default = config.my.home.email.mainAddress;
    };
    pinentry = mkPackageOption pkgs "pinentry" { } // {
      default = config.my.home.gpg.pinentry;
    };
    url = mkOption {
      type = types.str;
      default = "https://vaultwarden.whvdjsi.duckdns.org/";
    };
  };
  config = mkIf cfg.enable {
    programs.rbw = {
      enable = true;
      settings = {
        inherit (cfg) email pinentry;
        lock_timeout = 60 * 60 * 3;
        base_url = cfg.url;
        ui_url = cfg.url;
        sync_interval = 60 * 60;
      };
    };
    home.packages = [ pkgs.bitwarden ];
  };
}
