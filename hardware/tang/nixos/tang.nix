{ config, lib, ... }:
{
  services.tang = {
    enable = true;
    listenStream = [ "7654" ];
    ipAddressAllow = [
      "192.168.1.0/24"
      "10.5.0.1/16"
    ];
  };
  networking.firewall.allowedTCPPorts = map lib.strings.toInt config.services.tang.listenStream ++ [
    80
  ];
}
