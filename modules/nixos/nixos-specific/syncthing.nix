{
  config,
  lib,
  ...
}:
{
  networking.firewall =
    lib.mkIf config.home-manager.users.${config.my.user.username}.my.home.syncthing.enable
      {
        allowPing = true;
        allowedTCPPorts = [
          22000
        ];
        allowedUDPPorts = [
          22000
        ];
      };
}
