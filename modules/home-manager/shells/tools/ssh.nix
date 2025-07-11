{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.shell.tools.ssh;
in
{
  options.my.home.shell.tools.ssh.enable = mkEnableOption "Enable ssh config";
  config = mkIf cfg.enable {
    xdg.dataFile."ssh-control/.keep" = {
      enable = true;
      text = "";
    };
    programs.ssh = {
      enable = true;
      controlMaster = "auto";
      controlPersist = "yes";
      controlPath = "${config.xdg.dataHome}/ssh-control/%C";
      matchBlocks = rec {
        nasy = {
          port = 9639;
          hostname = "nasy.lan";
          user = "kirolsb";
        };
        nasy-bash = nasy // {
          extraOptions = {
            RemoteCommand = "bash -l";
            RequestTTY = "force";
          };
        };
        tang = {
          port = 9639;
          hostname = "tang.lan";
          user = "kirolsb";
        };
        macbook = {
          port = 9639;
          hostname = "Kirolss-MacBook-Pro.lan";
          user = "kirolsbakheat";
        };
        justice = {
          port = 9639;
          hostname = "justice.lan";
          user = "kirolsb";
        };
        xps = {
          port = 9639;
          hostname = "Kirols-xps9575.lan";
          user = "kirolsb";
        };
      };
      includes = [
        "config.d/*"
        config.age.secrets.ssh-config-private.path
      ];
    };
  };
}
