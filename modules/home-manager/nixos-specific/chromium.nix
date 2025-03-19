{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.chromium;
in
{
  options.my.home.chromium.enable = mkEnableOption "Enable chromium config";
  config = mkIf cfg.enable {
    programs.chromium = {
      package = pkgs.chromium.override {
        commandLineArgs = "--enable-features=TouchpadOverscrollHistoryNavigation,VaapiVideoDecode --ignore-gpu-blocklist --enable-gpu-rasterization";
      };
      enable = true;
      extensions = [
        # ublock origin
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }
        # bitwarden
        { id = "nngceckbapebfimnlniiiahkandclblb"; }
        # video speed controller
        { id = "nffaoalbilbmmfgbnbgppjihopabppdk"; }
        # sponsorblock
        { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; }
      ];
    };
  };
}
