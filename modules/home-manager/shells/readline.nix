{ lib, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.home.shell.readline;
in
{
  options.my.home.shell.readline.enable = mkEnableOption "Enable readline shell";
  config = mkIf cfg.enable {
    programs.readline = {
      enable = true;
      bindings = {
        "\\C-b" = "backward-kill-word";
      };
    };
  };
}
