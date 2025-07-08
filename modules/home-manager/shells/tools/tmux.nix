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
        tmuxinator.enable = false;
        tmuxp.enable = true;
        extraConfig = ''
          set  -g detach-on-destroy off
          set  -g base-index 1
          setw -g pane-base-index 1
          set  -g renumber-windows on

          is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
            | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

          bind-key x kill-pane # skip "kill-pane 1? (y/n)" prompt
          bind \\ split-window -h -c "#{pane_current_path}"
          bind - split-window -v -c "#{pane_current_path}"

          bind-key -n C-h  if-shell  "$is_vim"  "send-keys C-h"  "select-pane -L"
          bind-key -n C-j   if-shell  "$is_vim"  "send-keys C-j"   "select-pane -D"
          bind-key -n C-k  if-shell  "$is_vim"  "send-keys C-k"  "select-pane -U"
          bind-key -n C-l   if-shell  "$is_vim"  "send-keys C-l"   "select-pane -R"
          bind-key -n C-\   if-shell  "$is_vim"  "send-keys C-\\"  "select-pane -l"
        '';
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
            set -g @resurrect-processes 'false'
            ## Restore Panes
            set -g @resurrect-capture-pane-contents 'on'
            set -g @resurrect-dir '${config.xdg.stateHome}/tmux/resurrect/'
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
    catppuccin.tmux.extraConfig = ''
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
}
