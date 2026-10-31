{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption;
  cfg = config.my.gaming;
in
{
  options.my.gaming.enable = mkEnableOption "Install gaming dependencies";
  config = lib.mkIf cfg.enable {
    programs = {
      java.enable = true;
      steam = {
        enable = true;
        gamescopeSession.enable = true;
        localNetworkGameTransfers.openFirewall = true;
        remotePlay.openFirewall = true;
      };
    };
    environment.systemPackages = with pkgs; [
      steam-run
      config.programs.steam.package.run
      lutris
    ];
  };
}
