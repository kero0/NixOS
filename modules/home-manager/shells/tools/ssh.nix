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
    programs.ssh = {
      enable = true;
      controlMaster = "auto";
      controlPersist = "yes";
      controlPath = "~/.ssh/control/%C";
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
