{
  osConfig,
  ...
}:
{
  systemd.user.services.steam = {
    Unit = {
      Description = "Open Steam in the background at boot";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${osConfig.programs.steam.package} -nochatui -nofriendsui %U";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
