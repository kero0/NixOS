{
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
          relaysEnabled = false;
          globalAnnounceEnabled = false;
          localAnnounceEnabled = true;
          urAccepted = -1;
          crashReportingEnabled = false;

          listenAddresses = [
            "default"
          ];
          minHomeDiskFree = {
            unit = "%";
            value = 1;
          };
          defaults.ignores = [
            "(?d).DS_Store"
            "(?d).Spotlight-V100"
            "(?d).Trashes"
            "(?d)._*"
            "(?d).direnv"
            "(?d).venv"
            "(?d)Thumbs.db"
            "(?d)__pycache__"
            "(?d)desktop.ini"
            "(?d)ehthumbs.db"
            "(?d)result"
            "(?d)venv"
            "*.crdownload"
            "*.part"
          ];
        };
        folders = {
          Org = {
            path = "~/org";
            type = "sendreceive";
            versioning = {
              type = "simple";
              params.keep = "10";
            };
          };
          Documents = {
            path = "~/Documents";
            type = "sendreceive";
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
