{
  pkgs,
  lib,
  osconfig,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.shell.zsh;
  themepkg = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "zsh-syntax-highlighting";
    rev = "06d519c20798f0ebe275fc3a8101841faaeee8ea";
    hash = "sha256-Q7KmwUd9fblprL55W0Sf4g7lRcemnhjh4/v+TacJSfo=";
  };
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
      dotDir = ".config/zsh";

      history = {
        expireDuplicatesFirst = true;
        ignorePatterns =
          [ "*--login*" ]
          # command history for urls is not useful
          ++ lib.optional config.programs.gallery-dl.enable "gallery-dl*"
          ++ lib.optional (config.programs.yt-dlp.enable) "yt-dlp*";
        ignoreSpace = true;
        ignoreAllDups = true;

        path = "${config.xdg.dataHome}/zsh/history";
        share = true;

        save = 1 * 1000 * 1000;
        size = config.programs.zsh.history.save;
      };

      initExtra =
        let
          interactive_init =
            with pkgs;
            builtins.concatStringsSep "\n" [
              # use any-nix-shell to get nix-shell in zsh
              "source <(${any-nix-shell}/bin/any-nix-shell zsh --info-right)"

              # catppuccin
              "source '${themepkg}/themes/catppuccin_frappe-zsh-syntax-highlighting.zsh'"

              # show a random colorscript on startup
              "${dwt1-shell-color-scripts}/bin/colorscript random"

              # disable bell
              "unsetopt BEEP"

              # vim mode
              "source ${zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
              ''
                autoload edit-command-line; zle -N edit-command-line
                bindkey '^e' edit-command-line
                bindkey -M vicmd '^e' edit-command-line
              ''

              # Add kerybinding for atuin
              (lib.strings.optionalString config.programs.atuin.enable "bindkey '^r' atuin-search")
            ];
        in
        ''
          if [[ $options[interactive] = on ]]; then
             ${interactive_init}
          fi
        '';
    };
  };
}
