{ lib, ... }: {
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    settings = {
      format = "$all";
      right_format = " $nix_shell $git_status";
      battery = {
        full_symbol = "🔋 ";
        charging_symbol = "🔌 ";
        discharging_symbol = "⚡";
        unknown_symbol = "";
        display = [
          {
            threshold = 100;
            style = "bold green";
          }
          {
            threshold = 65;
            style = "green";
          }
          {
            threshold = 30;
            style = "bold yellow";
          }
          {
            threshold = 15;
            style = "bold red";
          }
        ];
      };
      c = {
        disabled = false;
        symbol = "C(bold blue)";
      };
      character = {
        error_symbol = "[✗](bold #ff0000)";
        success_symbol = "[❯](bold #ea00d9)";
        vicmd_symbol = "[V](bold green) ";
      };
      cmd_duration = {
        disabled = false;
        min_time = 1 * 1000;
        format = " took [$duration]($style)";
        show_notifications = true;
        min_time_to_notify = 45 * 1000;
      };
      directory = {
        truncation_length = 5;
        format = "[$path]($style)[$lock_symbol]($lock_style) ";
        style = "bold #f57800";
        read_only = "🔒";
        read_only_style = "bold white";
      };
      git_branch.symbol = " ";
      git_status = let
        ahead = "🏎";
        behind = "😰";
        conflicted = "⚡";
        deleted = "✘";
        diverged = "😵";
        modified = "📝";
        renamed = "➜";
        staged = "●";
        stashed = "📦";
        untracked = "…";
      in {
        conflicted = conflicted;
        ahead = "${ahead} ✕ $count";
        behind = "${behind} ✕ $count";
        diverged =
          "${diverged} ${ahead} ✕ $ahead_count ${behind} ✕ $behind_count";
        untracked = "${untracked} ✕ $count";
        stashed = "${stashed} ✕ $count";
        modified = "${modified} ✕ $count";
        staged = "${staged} ✕ $count";
        renamed = "${renamed} ✕ $count";
        deleted = "${deleted} ✕ $count";
        style = "bright-white";
        format = "$all_status$ahead_behind";
      };
      hostname = {
        disabled = false;
        ssh_only = true;
        format = "on [$hostname](bold pink)";
      };
      line_break.disabled = false;
      memory_usage = {
        disabled = false;
        threshold = 0;
        style = "bold dimmed white";
        symbol = "🐏 ";
        format = "$symbol[$ram( | $swap)]($style) ";
      };
      nix_shell = {
        disabled = false;
        symbol = "❄️";
        style = "bold blue";
        format = "via [$symbol $state ($name)]($style)";
        pure_msg = "";
        impure_msg = "";
      };
      package.disabled = true;
    };
  };
}
