{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.my.samba;
in
with lib;
{
  options.my.samba.enable = mkEnableOption "Enable samba";
  config = lib.mkIf cfg.enable {
    services = {
      samba =
        let
          hostname = config.networking.hostName;
        in
        {
          enable = true;
          nsswins = true;
          settings = {
            global = {
              workgroup = "WORKGROUP";
              "server string" = hostname;
              "netbios name" = hostname;
              security = "user";
              "map to guest" = "bad user";
              browseable = "yes";
              "follow symlinks" = "yes";
              "usershare allow guests" = "yes";
              "pam password change" = "yes";
              "client min protocol" = "NT1";
            };
            public = {
              path = "/home/${config.my.user.username}/winshare";
              "read only" = false;
              browseable = "yes";
              "guest ok" = "yes";
              comment = "Generic windows network share";
              "create mask" = "0644";
              "directory mask" = "0755";
              "force user" = "username";
              "force group" = "groupname";
            };
          };
        };
      samba-wsdd.enable = true;
      gvfs = {
        enable = true;
        package = lib.mkForce pkgs.gnome.gvfs;
      };

      avahi = {
        enable = true;
        nssmdns4 = true;
        nssmdns6 = true;
        publish = {
          enable = true;
          addresses = true;
          domain = true;
          hinfo = true;
          userServices = true;
          workstation = true;
        };
        extraServiceFiles = {
          smb = ''
            <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
            <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
            <service-group>
              <name replace-wildcards="yes">%h</name>
              <service>
                <type>_smb._tcp</type>
                <port>445</port>
              </service>
            </service-group>
          '';
        };
      };
    };
    networking.firewall = {
      allowPing = true;
      allowedTCPPorts = [
        445
        139
        5357
      ];
      allowedUDPPorts = [
        137
        138
        3702
      ];
      extraCommands = "iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns";
    };
  };
}
