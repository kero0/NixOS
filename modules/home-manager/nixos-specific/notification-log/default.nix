# THIS IS AI SLOP
{
  config,
  lib,
  pkgs,
  ...
}:
let
  log = "${config.xdg.stateHome}/notifications/log.jsonl";
  notifs = pkgs.writeShellApplication {
    name = "notifs";
    runtimeInputs = with pkgs; [
      coreutils
      fzf
      gnugrep
      gnused
      jq
      util-linux
      wl-clipboard
      xdg-utils
    ];
    text = ''
      log=${log}
      usage() {
        cat <<'EOF'
      usage: notifs                    browse them (newest first) in fzf
             notifs list [-n N] [--app TEXT] [--since 2h|1d]
             notifs show N             one in full (N from list; 1 = newest)
             notifs json               the record, one JSON object per line
             notifs clear              forget them all

      Every desktop notification since notification-log started, newest first
      (the last 5000). In the browser: Enter opens the first file or link in
      the notification, Ctrl-Y copies its text, Esc leaves.
      EOF
      }
      [ -s "$log" ] || { echo "notifs: none recorded yet ($log)"; exit 0; }

      # Newest first, numbered, markup stripped: N<TAB>time<TAB>app<TAB>summary<TAB>body
      rows() {
        tac "$log" | jq -r --slurp --arg since "''${1:-}" '
          to_entries[]
          | .key += 1
          | select($since == "" or .value.time >= $since)
          | [ (.key | tostring), .value.time[0:16], .value.app, .value.summary, .value.body ]
          | map(gsub("<[^>]*>"; "") | gsub("[\t\n]"; " "))
          | @tsv'
      }
      nth() { tac "$log" | sed -n "''${1}p"; }
      show() {
        nth "$1" | jq -r '"\(.time)  \(.app)  (\(.urgency))\n\n\(.summary)\n\n\(.body | gsub("<[^>]*>"; ""))"'
      }
      # The first path or URL in a notification's text
      target() {
        nth "$1" | jq -r '"\(.summary) \(.body)" | gsub("<[^>]*>"; " ")' |
          { grep -oE '(https?://[^[:space:]<>"]+|(^|[[:space:]])(~|/)[^[:space:]<>"]+)' || true; } |
          sed -n -e '1{s/^[[:space:]]*//' -e "s|^~|$HOME|" -e 'p}'
      }

      case ''${1:-} in
        "")
          # fzf runs these with my shell, so through this script
          self=${placeholder "out"}/bin/notifs
          rows | fzf --delimiter '\t' --with-nth 2,3,4 --no-sort --layout reverse \
            --header 'Enter: open its file or link · Ctrl-Y: copy its text · Esc: leave' \
            --preview "$self show {1}" --preview-window 'down,40%,wrap' \
            --bind "enter:execute-silent($self open {1})" \
            --bind "ctrl-y:execute-silent($self show {1} | wl-copy)" || true
          ;;
        open)
          t=$(target "''${2:?}")
          [ -n "$t" ] || exit 0
          setsid xdg-open "$t" >/dev/null 2>&1 &
          ;;
        list)
          shift
          n=20 app="" since=""
          while [ $# -gt 0 ]; do
            case $1 in
              -n) n=''${2:?-n takes a number}; shift ;;
              --app) app=''${2:?--app takes text}; shift ;;
              --since)
                d=''${2:?--since takes 30m, 2h or 1d}
                case $d in
                  *m) since=$(date -d "-''${d%m} minutes" --iso-8601=seconds) ;;
                  *h) since=$(date -d "-''${d%h} hours" --iso-8601=seconds) ;;
                  *d) since=$(date -d "-''${d%d} days" --iso-8601=seconds) ;;
                  *) echo "notifs: --since takes 30m, 2h or 1d" >&2; exit 2 ;;
                esac
                shift
                ;;
              *) usage >&2; exit 2 ;;
            esac
            shift
          done
          # awk rather than head: head closing the pipe early would fail it (pipefail)
          rows "$since" | { if [ -n "$app" ]; then grep -iF -- "$app" || true; else cat; fi; } |
            awk -F '\t' -v n="$n" 'NR <= n { printf "%4s  %s  %-14.14s %s\n", $1, $2, $3, $4 }'
          ;;
        show)
          [[ ''${2:-} =~ ^[0-9]+$ ]] || { echo "usage: notifs show N (N from notifs list)" >&2; exit 2; }
          show "$2"
          ;;
        json) cat "$log" ;;
        clear) : >"$log" ;;
        -h | --help | help) usage ;;
        *) usage >&2; exit 2 ;;
      esac
    '';
  };
in
{
  config = lib.mkIf config.my.home.notification-manager.enable {
    home.packages = [
      notifs
      (pkgs.man-pages.fromFiles { "notifs.1" = ./notifs.1.md; })
    ];

    systemd.user.services.notification-log = {
      Unit.Description = "Record desktop notifications for notifs";
      Service = {
        ExecStart = "${pkgs.python3}/bin/python3 -I ${./notification-log.py} ${log}";
        Environment = "PATH=${pkgs.systemd}/bin";
        Restart = "always";
        RestartSec = 5;
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
