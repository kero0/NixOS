{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption types;
  cfg = config.my.services.ssh;
in
{
  options.my.services.ssh = {
    enable = mkEnableOption "My openssh config";
    port = mkOption {
      type = types.port;
      default = if pkgs.stdenv.hostPlatform.isDarwin then 22 else 9639;
    };
  };
  config = lib.mkIf cfg.enable {
    services = {
      openssh = {
        enable = true;
      }
      // (
        if pkgs.stdenv.hostPlatform.isDarwin then
          {
            extraConfig = ''
              PasswordAuthentication no
              KbdInteractiveAuthentication no
              Port ${toString cfg.port}
            '';
          }
        else
          {
            settings = {
              PasswordAuthentication = false;
              KbdInteractiveAuthentication = false;
            };
            ports = [ cfg.port ];
          }
      );
    };
  };
}
