{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.my.server.enable = mkEnableOption "server hardening and maintenance";

  config = mkIf (pkgs.stdenv.isLinux && config.my.server.enable) {
    my.services.ssh.enable = true;

    security = {
      audit.enable = true;
      auditd.enable = true;
    };
    networking.firewall = {
      enable = true;
      logRefusedConnections = true;
    };

    services = {
      fail2ban = {
        enable = true;
        maxretry = 5;
        bantime = "12h";
      };
      openssh.settings = {
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
        AllowUsers = [ config.my.user.username ];
        MaxAuthTries = 3;
        LoginGraceTime = 20;
        AuthenticationMethods = "publickey";
        PermitTunnel = false;
      };
    };
  };
}
