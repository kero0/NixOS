{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
with lib;
let
  cfg = config.my.home.shell.zsh;
in
{
  options.my.home.shell.zsh.enable = mkEnableOption "zsh module";
  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting = {
        enable = true;
        highlighters = [
          "main" # the base highlighter, and the only one active by default.
          "brackets" # matches brackets and parenthesis.
          # "pattern" # matches user-defined patterns.
          # "regexp" # matches user-defined regular expressions.
          "cursor" # matches the cursor position.
          "root" # highlights the whole command line if the current user is root.
          # "line" # applied to the whole command line.
        ];
      };
      historySubstringSearch.enable = true;

      autocd = true;
      dotDir = "${lib.strings.removePrefix config.home.homeDirectory config.xdg.configHome}/zsh";

      history = {
        expireDuplicatesFirst = true;
        ignorePatterns =
          [
            "*--login*"
          ]
          # command history for urls is not useful
          ++ lib.optional config.programs.gallery-dl.enable "gallery-dl*"
          ++ lib.optional config.programs.yt-dlp.enable "yt-dlp*";
        ignoreSpace = true;
        ignoreAllDups = true;

        path = "${config.xdg.dataHome}/zsh/history";
        share = true;

        save = 1 * 1000 * 1000;
        size = config.programs.zsh.history.save;
      };

      initContent =
        let
          interactive_init =
            with pkgs;
            builtins.concatStringsSep "\n" [
              # use any-nix-shell to get nix-shell in zsh
              "source <(${any-nix-shell}/bin/any-nix-shell zsh --info-right)"

              # disable bell
              "unsetopt BEEP"

              # case insensitive completion
              "zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'"

              # pass unmatched globs to executables
              "setopt +o nomatch"

              # vim mode
              "source ${zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
              ''
                autoload edit-command-line; zle -N edit-command-line
                bindkey '^e' edit-command-line
                bindkey -M vicmd '^e' edit-command-line
              ''

              # change what counts as part of a word
              ''
                WORDCHARS=''${WORDCHARS/\/}
                WORDCHARS=''${WORDCHARS/\#}
                WORDCHARS=''${WORDCHARS/\$}
              ''

              # Add kerybinding for atuin
              (lib.strings.optionalString config.programs.atuin.enable "bindkey '^r' atuin-search")

              # emacs eat
              ''[ -n "$EAT_SHELL_INTEGRATION_DIR" ] && source "$EAT_SHELL_INTEGRATION_DIR/zsh"''

              # tmux
              (lib.strings.optionalString config.programs.tmux.enable ''
                  function sesh-sessions() {
                  {
                    exec </dev/tty
                      exec <&1
                      local session
                      session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
                      [[ -z "$session" ]] && return
                      sesh connect $session
                  }
                }

                zle     -N             sesh-sessions
                bindkey -M emacs '\es' sesh-sessions
                bindkey -M vicmd '\es' sesh-sessions
                bindkey -M viins '\es' sesh-sessions
                # check if in ssh or tmux
                [ -z "$TMUX$SSH_CONNECTION$SSH_TTY$SSH_CLIENT" ] && tmux attach
              '')
            ];
        in
        ''
          ${
            # home manager path
            (lib.strings.optionalString (osConfig == null) ''
              if [ -r  /etc/zshrc ]; then
                  . /etc/zshrc
              fi
            '')
          }
          if [[ $options[interactive] = on ]]; then
             ${interactive_init}
          fi
        '';
    };
  };
}
