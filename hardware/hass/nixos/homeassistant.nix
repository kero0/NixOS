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
        labels."io.containers.autoupdate" = "registry";
        extraOptions = [ "--network=host" ];
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
    };
    matter-server = {
      enable = true;
    };
  };
  networking.firewall = {
    allowedTCPPorts = [ 8123 ];
    allowedUDPPorts = [ 5353 ]; # mDNS, for HA's discovery
  };
  systemd.timers.podman-auto-update.wantedBy = [ "timers.target" ];

}
