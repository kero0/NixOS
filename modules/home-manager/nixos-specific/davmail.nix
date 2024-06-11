{
  pkgs,
  lib,
  osconfig,
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
      wantedBy = [ "graphical-session.target" ];
      script = ''${pkgs.davmail}/bin/davmail "${config.xdg.configDir}/${configFile}"'';
    };
  };
}
