{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.bat;
in
{
  options.my.home.bat.enable = mkEnableOption "Enable bat config";
  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [ batwatch ];
    };
  };
}
