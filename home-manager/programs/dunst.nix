{ pkgs, ... }:
{
  services.dunst = pkgs.lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "mouse";
        geometry = "600x5-25+25";
        indicate_hidden = true;
        shrink = false;
        transparency = 15;
        notification_height = 0;
        seperator_height = 1;
        padding = 8;
        horizontal_padding = 10;
        frame_width = 1;
        frame_color = "#282a36";
        separator_color = "frame";
        sort = true;
        idle_threshold = 120;
        font = "Monospace 10";
        line_height = 0;
        format = "%s %p\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        word_wrap = true;
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = true;
        icon_position = "left";
        min_icon_size = 0;
        sticky_history = true;
        history_length = 20;
        title = "Dunst";
        class = "Dunst";
        startup_notification = false;
      };
      urgency_low = {
        background = "#282a36";
        foreground = "#6272a4";
        timeout = 10;
      };
      urgency_normal = {
        background = "#282a36";
        foreground = "#bd93f9";
        timeout = 10;
      };

      urgency_critical = {
        background = "#ff5555";
        foreground = "#f8f8f2";
        timeout = 0;
      };
    };
  };
}
