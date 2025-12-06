{
  config,
  lib,
  myuser,
  ...
}:
{
  networking.firewall = lib.mkIf config.home-manager.users."${myuser}".my.home.syncthing.enable {
    allowPing = true;
    allowedTCPPorts = [
      22000
    ];
    allowedUDPPorts = [
      22000
    ];
  };
}
