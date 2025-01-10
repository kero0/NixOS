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
      matchBlocks = {
        nasy = {
          port = 9639;
          hostname = "nasy.lan";
          user = "kirolsb";
        };
        work-desktop = {
          port = 22;
          hostname = "10.5.10.26";
          user = "kbakheat-local";
        };
      };
      includes = [ "config.d/*" ];
    };
  };
}
