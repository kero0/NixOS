{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.shell.tools.tmux;
in
{
  options.my.home.shell.tools.tmux.enable = mkEnableOption "tmux module";
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ sesh ];
    programs = {
      fzf.tmux.enableShellIntegration = true;
      zsh.initExtra = # sh
        ''
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
        '';
      tmux = {
        enable = true;
        clock24 = false;
        historyLimit = 5000;
        keyMode = "vi";
        mouse = true;
        newSession = true;
        secureSocket = true;
        sensibleOnTop = true;
        terminal = "screen-256color";
        tmuxinator.enable = true;
        tmuxp.enable = true;
        extraConfig = ''
          bind-key x kill-pane # skip "kill-pane 1? (y/n)" prompt
          set -g detach-on-destroy off  # don't exit from tmux when closing a session
        '';
        catppuccin = {
          enable = true;
          extraConfig = ''
            set-option -g status-position top
            set -g @catppuccin_window_left_separator "█"
            set -g @catppuccin_window_right_separator "█ "
            set -g @catppuccin_window_number_position "right"
            set -g @catppuccin_window_middle_separator "  █"

            set -g @catppuccin_window_default_fill "number"

            set -g @catppuccin_window_current_fill "number"
            set -g @catppuccin_window_current_text "#{pane_current_path}"

            set -g @catppuccin_status_modules_right "application session date_time"
            set -g @catppuccin_status_left_separator  ""
            set -g @catppuccin_status_right_separator " "
            set -g @catppuccin_status_fill "all"
            set -g @catppuccin_status_connect_separator "yes"
          '';
        };
        plugins = with pkgs.tmuxPlugins; [
          better-mouse-mode
          sessionist # better session management
          tmux-fzf # manage tmux with fzf
          yank

          {
            # completion based on text on screen
            plugin = extrakto;
            extraConfig = ''
              # allow OSC52 to set the clipboard
              set -g set-clipboard on
              set -g @extrakto_clip_tool_run "tmux_osc52"
            '';
          }
          {
            # automatic save/restore of tmux
            plugin = continuum;
            extraConfig = ''
              set -g @continuum-restore 'on'
              set -g @continuum-save-interval '60' # minutes
            '';
          }
          {
            plugin = logging; # log session to file
            extraConfig = ''
              set -g @logging-path "${config.xdg.cacheHome}/tmux/logging/"
            '';
          }
          {
            # persist tmux across restarts
            plugin = resurrect;
            extraConfig = "
            set -g @resurrect-strategy-nvim 'session'
            set -g @resurrect-processes ':all:'
            ## Restore Vim sessions
            set -g @resurrect-strategy-vim 'session'
            ## Restore Neovim sessions
            set -g @resurrect-strategy-nvim 'session'
            ## Restore Panes
            set -g @resurrect-capture-pane-contents 'on'
            ";
          }
          {
            # which-key
            plugin = mkTmuxPlugin {
              pluginName = "tmux_which_key";
              version = "1.0";
              src = pkgs.fetchFromGitHub {
                owner = "alexwforsythe";
                repo = "tmux-which-key";
                rev = "1f419775caf136a60aac8e3a269b51ad10b51eb6";
                hash = "sha256-X7FunHrAexDgAlZfN+JOUJvXFZeyVj9yu6WRnxMEA8E=";
              };
            };
            extraConfig = ''
              set -g @tmux-which-key-disable-autobuild 1
            '';
          }
        ];
      };
    };
  };
}
