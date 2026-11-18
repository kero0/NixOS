{
  config,
  lib,
  pkgs,
  ...
}:
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
          CAP_NET_ADMIN = true;
          CAP_NET_BIND_SERVICE = true;
          CAP_NET_RAW = true;
        };
      };
    };
  };
  services = {
    esphome = {
      enable = true;
      openFirewall = true;
    };
    matterjs-server = {
      enable = true;
      # bluetoothSupport = true;
      openFirewall = true;
      port = 5581;
    };
  };
  networking.firewall = {
    allowedTCPPorts = [ 8123 ];
    allowedUDPPorts = [ 5353 ]; # mDNS, for HA's discovery
  };
  systemd = {
    timers = {
      podman-auto-update.wantedBy = [ "timers.target" ];
      update-containers = {
        timerConfig = {
          Unit = "update-containers.service";
          OnCalendar = "Sat 02:00";
        };
        wantedBy = [ "timers.target" ];
      };
    };
    services.update-containers = {
      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe (
          pkgs.writeShellScriptBin "update-containers" ''
            images=$(${pkgs.podman}/bin/podman ps -a --format="{{.Image}}" | sort -u)

            for image in $images; do
              ${pkgs.podman}/bin/podman pull "$image"
            done
          ''
        );
      };
    };
  };
}
