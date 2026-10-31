{ config, lib, ... }:
let
  cfg = config.my.autoUpgrade;
in
{
  options.my.autoUpgrade = {
    enable = lib.mkEnableOption "unattended upgrades from github:kero0/nixos (main is CI-gated)";
    allowReboot = lib.mkEnableOption "rebooting between 03:00 and 05:00 when the kernel or initrd changed";
  };
  config = lib.mkIf cfg.enable {
    system.autoUpgrade = {
      enable = true;
      flake = lib.mkDefault "github:kero0/nixos#${config.networking.hostName}";
      upgrade = false; # flake: no channel update
      dates = "03:30";
      randomizedDelaySec = "20min";
      inherit (cfg) allowReboot;
      rebootWindow = {
        lower = "03:00";
        upper = "05:00";
      };
    };
  };
}
