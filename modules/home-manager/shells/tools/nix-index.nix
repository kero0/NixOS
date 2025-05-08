{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  inherit (pkgs) comma;
  cfg = config.my.home.shell.tools.nix-index;
in
{
  options.my.home.shell.tools.nix-index.enable = mkEnableOption "Enable nix-index config";
  config = mkIf cfg.enable {
    home.sessionVariables = {
      NIX_AUTO_RUN = "1";
      NIX_AUTO_RUN_INTERACTIVE = "1";
    };
    programs = {
      nix-index = {
        enable = true;
        symlinkToCacheHome = true;
      };
      nix-index-database.comma.enable = true;
      fish.functions.__fish_command_not_found_handler = {
        body = "${comma}/bin/, $argv";
        onEvent = "fish_command_not_found";
      };
      zsh.initContent = lib.mkBefore ''
        if [[ $options[interactive] = on ]]; then
        	function command_not_found_handler() {
        	${comma}/bin/, "$@"
        	}
        fi
      '';
    };
  };
}
