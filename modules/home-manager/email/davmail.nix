{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.email.davmail;
in
{
  options.my.home.email.davmail = with types; {
    enable = mkEnableOption "Use davmail for Office accounts";
    configFile = mkOption {
      default = "davmail/davmail.properties";
      type = str;
      description = "Path to davmail config relative to `xdg.configHome`";
    };
    ports = {
      CalDav = mkOption {
        default = 1080;
        type = int;
        description = "CalDav port";
      };
      IMAP = mkOption {
        default = 1143;
        type = int;
        description = "IMAP port";
      };
      LDAP = mkOption {
        default = 1389;
        type = int;
        description = "LDAP port";
      };
      SMTP = mkOption {
        default = 1025;
        type = int;
        description = "SMTP port";
      };
    };
  };
  config = mkIf cfg.enable {
    xdg.configFile.${cfg.configFile}.text = ''
      davmail.caldavPort=${toString cfg.ports.CalDav}
      davmail.imapPort=${toString cfg.ports.IMAP}
      davmail.ldapPort=${toString cfg.ports.LDAP}
      davmail.smtpPort=${toString cfg.ports.SMTP}
      davmail.url=https://outlook.office365.com/EWS/Exchange.asmx
      davmail.mode=O365Interactive
      davmail.server=true

    '';
    launchd.agents.davmail = mkIf config.launchd.enable {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.davmail}/bin/davmail"
          "${config.xdg.configHome}/${cfg.configFile}"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardErrorPath = "/tmp/davmail.err.log";
        StandardOutPath = "/tmp/davmail.out.log";
      };
    };
  };
}
