{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.my.gaming;
in
with lib;
{
  options.my.gaming.enable = mkEnableOption "Install gaming dependencies";
  config = lib.mkIf cfg.enable {
    programs = {
      java.enable = true;
      steam = {
        enable = true;
        gamescopeSession.enable = true;
        extraCompatPackages = with pkgs; [ proton-ge-bin ];
        package = pkgs.steam.override { };
        localNetworkGameTransfers.openFirewall = true;
        remotePlay.openFirewall = true;
      };
    };
    environment.systemPackages = with pkgs; [
      steam-run-native
      config.programs.steam.package.run
      lutris
    ];
  };
}
