{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.ssh;
in
with lib;
{
  options.my.services.ssh = {
    enable = mkEnableOption "My openssh config";
    port = mkOption {
      type = types.port;
      default = 9639;
    };
  };
  config = lib.mkIf cfg.enable {
    services = {
      openssh =
        {
          enable = true;
        }
        // (
          if pkgs.stdenv.isDarwin then
            {
              extraConfig = ''
                PasswordAuthentication no
                Port ${toString cfg.port}
              '';
            }
          else
            {
              settings.PasswordAuthentication = false;
              ports = [ cfg.port ];
            }
        );
    };
  };
}
