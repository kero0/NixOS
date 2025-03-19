{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.shell.tools.bat;
in
{
  options.my.home.shell.tools.bat.enable = mkEnableOption "Enable bat config";
  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [ batwatch ];
    };
  };
}
