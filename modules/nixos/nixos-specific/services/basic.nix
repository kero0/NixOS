{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption;
  cfg = config.my.services.basic;
in
{
  options.my.services.basic.enable = mkEnableOption "Basic linux services";
  config = lib.mkIf cfg.enable {
    services = {
      dbus.implementation = "broker";
      gvfs.enable = true;
      journald.settings.Journal.SystemMaxUse = "100M";
      smartd = {
        enable = true;
        notifications.systembus-notify.enable = config.my.desktop.enable;
      };
    };
    documentation.man.cache.enable = true;
  };
}
