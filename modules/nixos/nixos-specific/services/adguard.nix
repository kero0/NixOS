{
  config,
  lib,
  ...
}:
let
  cfg = config.my.services.adguardserver;
in
with lib;
{
  options.my.services.adguardserver = {
    enable = mkEnableOption "AdGuard Home DNS server";
    bind_hosts = mkOption {
      type = with lib.types; listOf str;
      default = [
        "0.0.0.0"
        "::"
      ];
      description = "List of hosts to bind AdGuard Home to.";
    };
    openPorts = mkEnableOption "Open firewall ports for AdGuard Home";
    httpPort = mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port for the AdGuard Home web interface.";
    };
  };
  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 53 ] ++ lib.optional cfg.openPorts cfg.httpPort;
    networking.firewall.allowedUDPPorts = [ 53 ] ++ lib.optional cfg.openPorts cfg.httpPort;
    services.adguardhome = {
      enable = true;
      mutableSettings = false;
      host = "127.0.0.1";
      port = cfg.httpPort;
      settings = {
        dns = {
          inherit (cfg) bind_hosts;
          port = 53;
          upstream_dns = [
            "https://dns.quad9.net/dns-query"
            "https://dns.cloudflare.com/dns-query"
          ];
          bootstrap_dns = [
            "9.9.9.9"
            "1.1.1.1"
          ];
        };
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];
        users = [ ];
        filters_update_interval = 24;
        querylog.interval = "${toString (7 * 24)}h";
        filtering = {
          protection_enabled = true;
          filtering_enabled = true;
          parental_enabled = false;
          safe_search.enabled = false;
          rewrites = [
            {
              enabled = true;
              domain = "*.whvdjsi.duckdns.org";
              answer = "nasy.localdomain";
            }
            {
              enabled = true;
              domain = "*.kirols.duckdns.org";
              answer = "nasy.localdomain";
            }
            {
              enabled = true;
              domain = "whvdjsi.duckdns.org";
              answer = "nasy.localdomain";
            }
            {
              enabled = true;
              domain = "kirols.duckdns.org";
              answer = "nasy.localdomain";
            }
          ];
        };
        filters = [
          {
            id = 1;
            enabled = true;
            name = "AdGuard DNS filter";
            url = "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt";
          }
          {
            id = 2;
            enabled = true;
            name = "OISD Basic";
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
          }
          {
            id = 3;
            enabled = true;
            name = "AdGuard Mobile Ads";
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_4.txt";
          }
        ];
      };
    };
  };
}
