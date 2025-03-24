{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.shell.tools.tealdeer;
in
{
  options.my.home.shell.tools.tealdeer.enable = mkEnableOption "Enable tealdeer config";
  config = mkIf cfg.enable {
    programs.tealdeer = {
      enable = true;
      settings = {
        display = {
          use_pager = true;
          compact = false;
        };
        updates = {
          auto_update = true;
          auto_update_interval_hours = 4 * 24;
        };
        directories.cache_dir = "${config.xdg.cacheHome}/tealdeer";
      };
    };
  };
}
