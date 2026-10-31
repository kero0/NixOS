{ config, ... }:
{
  system.switch.inhibitors.systemd = config.systemd.package.version;
  security.sudo.wheelNeedsPassword = false;
  services.journald.settings.Journal.SystemMaxUse = "100M";
  services.smartd.enable = true;
  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };
}
