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
    programs = {
      direnv.enableBashIntegration = false; # direnv needs to be before blesh
      bash = {
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
        initExtra =
          let
            interactive_init = builtins.concatStringsSep "\n" [
              # direnv
              (strings.optionalString config.programs.direnv.enable ''
                eval "$(${config.programs.direnv.package}/bin/direnv hook bash)"
              '')

              # tmux
              (strings.optionalString config.programs.tmux.enable ''
                    if [ -z "$TMUX" ]; then
                  exec ${config.programs.tmux.package}/bin/tmux attach
                fi
              '')

              # emacs eat
              ''
                [ -n "$EAT_SHELL_INTEGRATION_DIR" ] && source "$EAT_SHELL_INTEGRATION_DIR/bash"
              ''

              # blesh
              ''
                source ${pkgs.blesh}/share/blesh/ble.sh
              ''
            ];
          in
          mkAfter ''
            [ -r $HOME/.bashrc-local ] && source $HOME/.bashrc-local
            ${interactive_init}
          '';
      };
    };
  };
}
