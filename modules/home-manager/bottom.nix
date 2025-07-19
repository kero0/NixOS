{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.bottom;
in
{
  options.my.home.bottom.enable = mkEnableOption "Enable bottom config";
  config = mkIf cfg.enable {
    programs.bottom = {
      enable = true;
      settings = {
        flags = {
          avg_cpu = true;
          temperature_type = "c";
          rate = 1000;
          cpu_left_legend = false;
          current_usage = false;
          group_processes = false;
          case_sensitive = false;
          whole_word = false;
          regex = true;
          default_widget_type = "cpu";
          default_widget_count = 1;
        };
        disk = {
          columns = [
            "Disk"
            "Mount"
            "Used"
            "Free"
            "Total"
            "Used%"
            "R/s"
            "W/s"
          ];
        };
      };
    };
  };
}
