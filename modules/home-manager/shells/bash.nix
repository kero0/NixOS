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
      historyControl = [
        "erasedups"
        "ignoreboth"
      ];
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
      bashrcExtra =
        let
          interactive_init = builtins.concatStringsSep "\n" [

            # tmux
            (strings.optionalString config.programs.tmux.enable ''
              if [ -z "$TMUX" ]; then
                exec ${config.programs.tmux.package}/bin/tmux attach
              fi
            '')

            # emacs eat
            ''[ -n "$EAT_SHELL_INTEGRATION_DIR" ] && source "$EAT_SHELL_INTEGRATION_DIR/bash"''

            # blesh
            "source ${pkgs.blesh}/share/blesh/ble.sh"
          ];
        in
        ''
          [ -r $HOME/.bashrc-local ] && source $HOME/.bashrc-local
          if [[ $- == *i* ]]; then
             ${interactive_init}
          fi
        '';
    };
  };
}
