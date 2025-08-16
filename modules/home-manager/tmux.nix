{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.tmux;
in
{
  options.my.home.tmux.enable = mkEnableOption "tmux module";
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ansifilter
      sesh
    ];
    programs = {
      fzf.tmux.enableShellIntegration = true;
      tmux = {
        enable = true;
        clock24 = false;
        focusEvents = true;
        historyLimit = 50000;
        keyMode = "vi";
        mouse = true;
        newSession = true;
        secureSocket = false;
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

          bind-key -n C-h  if-shell  "$is_vim"  "send-keys C-h"  "select-pane -L"
          bind-key -n C-j   if-shell  "$is_vim"  "send-keys C-j"   "select-pane -D"
          bind-key -n C-k  if-shell  "$is_vim"  "send-keys C-k"  "select-pane -U"
          bind-key -n C-l   if-shell  "$is_vim"  "send-keys C-l"   "select-pane -R"
          bind-key -n C-\   if-shell  "$is_vim"  "send-keys C-\\"  "select-pane -l"
          bind-key -r "<" swap-window -d -t -1
          bind-key -r ">" swap-window -d -t +1

          set-option -s escape-time 0
          set-option -g display-time 4000
          set-option -g status-interval 5

          set-option -s default-terminal "screen-256color"
          set-option -g status-keys emacs
          set-window-option -g aggressive-resize on

          bind-key C-p previous-window
          bind-key C-n next-window

        '';
        plugins = with pkgs.tmuxPlugins; [
          better-mouse-mode
          sessionist
          tmux-fzf
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
            plugin = resurrect;
            extraConfig = "
            set -g @resurrect-processes 'false'
            ## Restore Panes
            set -g @resurrect-capture-pane-contents 'on'
            set -g @resurrect-dir '${config.xdg.stateHome}/tmux/resurrect/'
            ";
          }
          {
            plugin = mkTmuxPlugin {
              pluginName = "tmux-ssh-split";
              version = "1.0";
              rtpFilePath = "ssh-split.tmux";
              src = pkgs.fetchFromGitHub {
                owner = "pschmitt";
                repo = "tmux-ssh-split";
                rev = "f103c56f71ec947027bef028eeed8d171173e9cf";
                hash = "sha256-SCUBH/DAfWTZPieUT+YOXIxg0eolYnGTZArsbAgF4C8=";
              };
            };
            extraConfig = ''
              set-option -g @ssh-split-keep-cwd "true"
              set-option -g @ssh-split-keep-remote-cwd "true"
              set-option -g @ssh-split-fail "false"
              set-option -g @ssh-split-no-env "false"
              set-option -g @ssh-split-no-shell "false"
              set-option -g @ssh-split-strip-cmd "true"
              set-option -g @ssh-split-verbose "true"
              set-option -g @ssh-split-debug "false"
              set-option -g @ssh-split-h-key "\\"
              set-option -g @ssh-split-v-key "-"
              set-option -g @ssh-split-w-key "c"
              set-option -g @ssh-split-r-key "r"
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
