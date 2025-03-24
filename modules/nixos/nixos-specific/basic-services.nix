{ config, lib, ... }:
let
  cfg = config.my.basic-services;
in
with lib;
{
  options.my.basic-services.enable = mkEnableOption "Basic linux services";
  config = lib.mkIf cfg.enable {
    services = {
      dbus.implementation = "broker";
      flatpak.enable = true;
      gvfs.enable = true;
      journald.extraConfig = "SystemMaxUse=100M";
      onedrive.enable = true;
      openssh = {
        enable = true;
        # settings.PasswordAuthentication = false;
        ports = [ 9639 ];
      };
    };
  };
}
