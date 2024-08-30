{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.shell.bash;
in
{
  options.my.home.shell.bash.enable = mkEnableOption "bash module";
  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
      historyControl = true;
      historyFile = "${config.xdg.cacheHome}/bash-history";
      historyFileSize = 1000 * 1000;
      historyIgnore = [
        "reset"
        "cd"
        "ls"
      ];
      shellOptions = [
        "histappend"
        "checkwinsize"
        "extglob"
        "globstar"
        "checkjobs"
      ];
    };
  };
}
