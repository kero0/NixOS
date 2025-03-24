{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.email.davmail;
  configFile = "davmail/davmail.properties";
in
{
  config = mkIf cfg.enable {
    systemd.user.services.davmail = {
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = ''${pkgs.davmail}/bin/davmail "${config.xdg.configHome}/${configFile}"'';
      };
    };
  };
}
