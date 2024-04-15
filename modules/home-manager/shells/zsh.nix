{ pkgs, lib, osconfig, config, ... }:
with lib;
let
  cfg = config.my.home.shell.zsh;
in
{
  options.my.home.shell.zsh.enable = mkEnableOption "zsh module";
  config = mkIf cfg.enable
    {
      programs.zsh = {
        enable = true;
        autosuggestion.enable = true;
        enableCompletion = true;
        syntaxHighlighting.enable = true;

        autocd = true;
        dotDir = ".config/zsh";

        envExtra = ''
          export EDITOR=vim
          export VISUAL='emacsclient -c -a ""'
        '';
        sessionVariables = {
          ZSH_HIGHLIGHT_HIGHLIGHTERS = [
            "main" # the base highlighter, and the only one active by default.
            "brackets" # matches brackets and parenthesis.
            # "pattern" # matches user-defined patterns.
            # "regexp" # matches user-defined regular expressions.
            "cursor" # matches the cursor position.
            # "root" # highlights the whole command line if the current user is root.
            "line" # applied to the whole command line.
          ];
        };

        history = {
          expireDuplicatesFirst = true;
          ignorePatterns = [
            "*--login*"
          ]
          # command history for urls is not useful
          ++ lib.optional config.programs.gallery-dl.enable "gallery-dl*"
          ++ lib.optional (config.programs.yt-dlp.enable) "yt-dlp*";
          ignoreSpace = true;

          path = "${config.xdg.dataHome}/zsh/history";
          share = true;

          save = 10 * 1000;
          size = config.programs.zsh.history.save;
        };

        initExtra =
          let
            interactive_init = with pkgs;
              builtins.concatStringsSep "\n" [
                # use any-nix-shell to get nix-shell in zsh
                "source <(${any-nix-shell}/bin/any-nix-shell zsh --info-right)"

                # show a random colorscript on startup
                "${dwt1-shell-color-scripts}/bin/colorscript random"

                # use , to search for commands
                ''
                  function command_not_found_handler() {
                    ${comma}/bin/, "$@"
                  }
                ''

                # disable bell
                "unsetopt BEEP"

                # vim mode
                "source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
              ];
            in
            ''
            if [[ $options[interactive] = on ]]; then
               ${interactive_init}
            fi
          '';

        historySubstringSearch.enable = true;
      };
    };
}
