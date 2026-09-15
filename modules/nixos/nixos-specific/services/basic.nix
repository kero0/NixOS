{
  config,
  lib,
  ...
}:
let
  cfg = config.my.services.basic;
in
with lib;
{
  options.my.services.basic.enable = mkEnableOption "Basic linux services";
  config = lib.mkIf cfg.enable {
    services = {
      dbus.implementation = "broker";
      gvfs.enable = true;
      journald.settings.Journal.SystemMaxUse = "100M";
    };
  };
}
