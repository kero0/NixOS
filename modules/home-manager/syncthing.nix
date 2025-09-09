{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.syncthing;
in
{
  options.my.home.syncthing = {
    enable = mkEnableOption "Enable syncthing config";
  };
  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      overrideDevices = false;
      overrideFolders = false;
      settings = {
        options = {
          listenAddresses = [
            "default"
          ];
          minHomeDiskFree = {
            unit = "%";
            value = 1;
          };
          localAnnounceEnabled = true;
          urAccepted = -1;
        };
        folders = {
          Org = {
            path = "~/org";
            versioning = {
              type = "simple";
              params.keep = "10";
            };
          };
          Documents = {
            path = "~/Documents";
            versioning = {
              type = "simple";
              params.keep = "10";
            };
          };
        };
      };
    };
  };
}
