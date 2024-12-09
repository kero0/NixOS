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
      matchBlocks.nasy = {
        port = 9639;
        hostname = "nasy.lan";
        user = "kirolsb";
      };
      includes = [ "config.d/*" ];
    };
  };
}
