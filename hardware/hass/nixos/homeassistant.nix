{ config, ... }:
{
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      homeassistant = {
        volumes = [ "homeassistant:/config" ];
        environment = {
          TZ = config.time.timeZone;
        };
        image = "ghcr.io/home-assistant/home-assistant:stable";
        ports = [ "8123:8123" ];
        capabilities = {
          CAP_NET_RAW = true;
          CAP_NET_BIND_SERVICE = true;
        };
      };
    };
  };
  services = {
    esphome = {
      enable = true;
      openFirewall = true;
      usePing = true;
    };
    matter-server = {
      enable = true;
    };
  };
  networking.firewall.allowedTCPPorts = [ config.services.matter-server.port ];

}
