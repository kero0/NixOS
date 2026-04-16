{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkOption types concatMapStringsSep;
  cfg = config.my.default-apps;
  mkCommand = app: "${pkgs.openwith}/bin/openwith ${app.app_id} ${app.extension}";
  commands = concatMapStringsSep "\n" mkCommand cfg;
in
{
  options.my.default-apps = mkOption {
    type = types.listOf (
      types.submodule {
        options = {
          app_id = mkOption {
            type = types.str;
            description = "Application bundle identifier";
          };

          extension = mkOption {
            type = types.str;
            description = "File extension";
          };
        };
      }
    );
    default = [ ];
    description = "Declarative default application mappings via duti.";
  };

  config = lib.mkIf (cfg != [ ] && pkgs.stdenv.isDarwin) {
    home.packages = [ pkgs.openwith ];
    home.activation.my-default-apps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run echo "Setting default apps"
      run ${commands}
    '';
  };
}
