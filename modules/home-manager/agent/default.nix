{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.my.home.agent;
  inherit (cfg) user;

  command = types.submodule {
    options = {
      description = mkOption { type = types.str; };
      usage = mkOption {
        type = types.str;
        default = "";
        description = "Argument synopsis shown in `agent help`.";
      };
      help = mkOption {
        type = types.lines;
        default = "";
        description = ''
          The details, for `agent help <command>`, `agent <command> --help` and
          agent(1): what it does, its arguments and options, examples. Plain
          paragraphs, `- ` lists and `code`, so it reads the same in a
          terminal and turns into a man page.
        '';
      };
      script = mkOption {
        type = types.lines;
        description = "Bash run for the subcommand; \"$@\" holds its arguments and $host the configured host.";
      };
      zshCompletion = mkOption {
        type = types.lines;
        default = "";
        description = "zsh completion code, with words shifted so $words[1] is the subcommand.";
      };
      bashCompletion = mkOption {
        type = types.lines;
        default = "";
        description = "bash completion code; $cur and $prev are set, fill COMPREPLY.";
      };
    };
  };

  pad = n: s: s + lib.concatStrings (lib.replicate (lib.max 1 (n - lib.stringLength s)) " ");
  usage = pkgs.writeText "agent-usage" ''
    usage: agent [command] [args...]   (no command: attach)

    ${lib.concatStrings (
      lib.mapAttrsToList (name: c: "  ${pad 40 "${name} ${c.usage}"} ${c.description}\n") cfg.commands
    )}
    agent help <command> (or agent <command> --help) explains a command, with
    examples; man agent has all of them. The host comes from
    ${"$"}{XDG_CONFIG_HOME:-~/.config}/agent/config; AGENT_HOST or --host override it.
  '';

  # agent help <command>
  commandHelp = lib.mapAttrs (
    name: c:
    pkgs.writeText "agent-help-${name}" ''
      usage: agent ${name}${lib.optionalString (c.usage != "") " ${c.usage}"}

      ${lib.toUpper (lib.substring 0 1 c.description)}${lib.substring 1 (-1) c.description}.
      ${lib.optionalString (c.help != "") "\n${c.help}"}
      See also: man agent
    ''
  ) cfg.commands;

  # agent(1), from the same descriptions and help
  manPage = pkgs.man-pages.fromMarkdown "agent.1" ''
    % AGENT(1) | Agent sandbox

    # NAME

    agent - drive the sandboxed AI agent: sessions, access, runs and upkeep

    # SYNOPSIS

    **agent** [*command*] [*args*...]

    **agent help** [*command*]

    **agent** *command* **--help**

    # DESCRIPTION

    ${cfg.manDescription}

    **agent** with no command attaches to the orchestrator. Commands that act
    on the sandbox itself exist only on the machine running it; elsewhere
    **agent** reaches it over ssh, at the host in the config (${cfg.host}
    here).

    # COMMANDS

    ${lib.concatStrings (
      lib.mapAttrsToList (name: c: ''
        ## agent ${name} ${
          lib.replaceStrings [ "*" "<" ">" "|" "[" "]" ] [ "\\*" "\\<" "\\>" "\\|" "\\[" "\\]" ] c.usage
        }

        ${lib.toUpper (lib.substring 0 1 c.description)}${lib.substring 1 (-1) c.description}.

        ${c.help}

      '') cfg.commands
    )}
    # ENVIRONMENT

    AGENT_HOST
    :   The machine running the sandbox, instead of the configured one. Most
        commands that reach it also take **--host** *host*.

    # FILES

    ${"$"}{XDG_CONFIG_HOME:-~/.config}/agent/config
    :   **host = **_name_: the machine running the sandbox (here ${cfg.host}).

    ~/Projects/<session>
    :   On the machine running the sandbox: a project session's /work.

    # SEE ALSO

    ${cfg.manSeeAlso}
  '';

  cli = pkgs.writeShellScriptBin "agent" ''
    set -euo pipefail
    config=''${XDG_CONFIG_HOME:-$HOME/.config}/agent/config
    host=
    [ -r "$config" ] && host=$(${pkgs.gnused}/bin/sed -n 's/^host *= *//p' "$config" | tail -n 1)
    host=''${AGENT_HOST:-''${host:-localhost}}

    cmd=''${1:-attach}
    [ $# -gt 0 ] && shift
    case "$cmd:''${1:-}" in
    ${lib.concatStrings (
      lib.mapAttrsToList (name: h: ''
        help:${name} | ${name}:-h | ${name}:--help) exec cat ${h} ;;
      '') commandHelp
    )}
      help:?*)
        echo "agent: no command '$1' (agent help lists them)" >&2
        exit 1
        ;;
    esac
    case "$cmd" in
    ${lib.concatStrings (
      lib.mapAttrsToList (name: c: ''
        ${name})
        ${c.script}
          ;;
      '') cfg.commands
    )}
      help | -h | --help) cat ${usage} ;;
      *)
        echo "agent: no command '$cmd'" >&2
        cat ${usage} >&2
        exit 1
        ;;
    esac
  '';

  completions = pkgs.runCommand "agent-completions" { } ''
    install -Dm644 ${pkgs.writeText "_agent" ''
      #compdef agent
      _agent() {
        local -a commands
        commands=(
          ${lib.concatMapStringsSep "\n    " (
            n: lib.escapeShellArg "${n}:${cfg.commands.${n}.description}"
          ) (lib.attrNames cfg.commands)}
        )
        if (( CURRENT == 2 )); then
          _describe 'agent command' commands
          return
        fi
        local cmd=$words[2]
        shift words
        (( CURRENT-- ))
        case $cmd in
          ${lib.concatStrings (
            lib.mapAttrsToList (name: c: ''
              ${name})
              ${c.zshCompletion}
                ;;
            '') (lib.filterAttrs (_: c: c.zshCompletion != "") cfg.commands)
          )}
        esac
      }
      _agent "$@"
    ''} $out/share/zsh/site-functions/_agent
    install -Dm644 ${pkgs.writeText "agent.bash" ''
      _agent() {
        local cur=''${COMP_WORDS[COMP_CWORD]} prev=''${COMP_WORDS[COMP_CWORD-1]}
        if (( COMP_CWORD == 1 )); then
          mapfile -t COMPREPLY < <(compgen -W ${lib.escapeShellArg (toString (lib.attrNames cfg.commands))} -- "$cur")
          return
        fi
        case ''${COMP_WORDS[1]} in
          ${lib.concatStrings (
            lib.mapAttrsToList (name: c: ''
              ${name})
              ${c.bashCompletion}
                ;;
            '') (lib.filterAttrs (_: c: c.bashCompletion != "") cfg.commands)
          )}
        esac
      }
      complete -F _agent agent
    ''} $out/share/bash-completion/completions/agent
  '';
in
{
  options.my.home.agent = {
    enable = lib.mkEnableOption "the `agent` command for the sandboxed AI agent";
    host = mkOption {
      type = types.str;
      default = "localhost";
      example = "pop-os";
      description = "Machine running the agent sandbox; written to ~/.config/agent/config.";
    };
    user = mkOption {
      type = types.str;
      default = "agent";
      description = "The account the sandbox runs as on the host; ssh goes to it.";
    };
    webPort = mkOption {
      type = types.port;
      default = 8083;
      description = "Port of the sandbox's zellij web client (https://<host>:<port>/<session>).";
    };
    sessionsDir = mkOption {
      type = types.str;
      default = "Projects/.agent/sessions";
      description = "Where the project sessions are on the host, relative to my home there (agent remote).";
    };
    clipboardMaxAge = mkOption {
      type = types.int;
      default = 600;
      description = "Seconds an image sent with agent paste stays pasteable (the host enforces it; this is for the help).";
    };
    manDescription = mkOption {
      type = types.lines;
      default = ''
        The agent runs as the **${cfg.user}** user on ${cfg.host}, in containers:
        the orchestrator (what **agent attach** opens) and one container per
        project session, each with its own /work.
      '';
      description = "What the sandbox is, for agent(1)'s DESCRIPTION (markdown).";
    };
    manSeeAlso = mkOption {
      type = types.lines;
      default = "**ssh**(1), **zellij**(1)";
      description = "agent(1)'s SEE ALSO (markdown).";
    };
    commands = mkOption {
      type = types.attrsOf command;
      default = { };
      description = "Subcommands of `agent`; the machine running the sandbox adds its admin commands here.";
    };
    hostUser = mkOption {
      type = types.str;
      default = config.home.username;
      description = "My account on the host, for syncing projects to it (agent remote).";
    };
    clipboardPut = mkOption {
      type = types.nullOr types.str;
      default = null;
      internal = true;
      description = "On the host: puts an image where the agents' Claude Code pastes from (agent paste).";
    };
    workspaceDiff = mkOption {
      type = types.nullOr types.str;
      default = null;
      internal = true;
      description = "On the host: prints a session workspace's changes (agent remote diff).";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      cli
      completions
      manPage
    ];

    xdg.configFile."agent/config".text = ''
      # Machine running the agent sandbox, used by `agent attach` and `agent prompt`.
      # AGENT_HOST or --host override it for a single call.
      host = ${cfg.host}
    '';

    my.home.agent.commands = {
      attach = {
        usage = "[host]";
        description = "attach to the orchestrator session";
        help = ''
          Opens the orchestrator, the main agent session: a zellij session in the
          orchestrator container, reached over ssh as the `${user}` user and created
          if it isn't running. `agent` with no command does the same. Detaching
          (zellij's detach) leaves it running.

          - `host`: the machine to attach to, instead of the configured one (or
            AGENT_HOST).

          Your ssh key has to be authorized first: `agent authorize` on the host.

          Examples:

              agent
              agent attach pop-os
        '';
        script = ''exec ssh -t ${user}@"''${1:-$host}"'';
        zshCompletion = "_hosts";
        bashCompletion = ''mapfile -t COMPREPLY < <(compgen -A hostname -- "$cur")'';
      };

      session = {
        usage = "<name> [host]";
        description = "open a project's session (the same as https://<host>:8083/<name>)";
        help = ''
          Opens a project session: its own container and zellij session, with its
          own /work, which you see as ~/Projects/<name> on the host. It's created
          the first time you open it and keeps running when you detach. It's the
          same session as https://<host>:${toString cfg.webPort}/<name> in a browser.

          - `name`: the session, e.g. a ticket key: letters, digits, `.`, `_` and
            `-`, starting with a letter or digit, up to 63 characters.
          - `host`: the machine running the sandbox, instead of the configured one.

          Examples:

              agent session POS-1234
              agent session camera-hal pop-os
        '';
        script = ''
          [ -n "''${1:-}" ] || { echo "usage: agent session <name> [host], e.g. agent session POS-1234   (agent help session)" >&2; exit 2; }
          name=''${1}
          [[ $name =~ ^[A-Za-z0-9][A-Za-z0-9._-]{0,62}$ ]] || { echo "agent: session names are letters, digits, . _ -" >&2; exit 1; }
          exec ssh -t ${user}@"''${2:-$host}" session "$name"
        '';
        zshCompletion = "_message 'session name, e.g. a ticket key'";
      };

      # Working on a project from another device: rsync it into a session's
      # dropbox (/work/incoming/<name> for the agent), the agent imports it as
      # a workspace, and its changes come back as a patch
      progress = {
        usage = "<session> [--model m] [--raw]";
        description = "how a session's agent (or its overnight run) is doing, without interrupting it";
        help = ''
          A status report on the agent working in a session, its subagents, and
          an overnight run if one is going: what it's doing now and since when,
          what it's done and found, errors or signs it's stuck or waiting on you,
          and what's next. A separate, read-only model in the session's
          container writes it from what the agent leaves behind (its live
          transcripts, the overnight log, /work/progress.md), so the agent
          itself is never interrupted. It takes a minute or two.

          - `session`: the session, e.g. POS-1234, or `orchestrator`.
          - `--model m`: sonnet (the default), haiku (quicker) or opus.
          - `--raw`: print the condensed activity itself (prompts, tool calls,
            results, the overnight log), no model.

          Inside a session, `progress` in its shell tab, or `/progress` in a
          Claude there, does the same.

          Examples:

              agent progress POS-1234
              agent progress POS-1234 --model haiku
              agent progress POS-1234 --raw | less
        '';
        script = ''
          session="" model=sonnet mode=summary
          while [ $# -gt 0 ]; do
            case $1 in
              --model) model=''${2:-}; shift ;;
              --raw) mode=raw ;;
              -*) echo "agent progress: unknown option $1 (agent help progress)" >&2; exit 2 ;;
              *) session=$1 ;;
            esac
            shift
          done
          [[ $session =~ ^[A-Za-z0-9][A-Za-z0-9._-]{0,62}$ ]] ||
            { echo "usage: agent progress <session> [--model sonnet|haiku|opus] [--raw]   (agent help progress)" >&2; exit 2; }
          case $model in sonnet | haiku | opus) ;; *) echo "agent progress: --model takes sonnet, haiku or opus" >&2; exit 2 ;; esac
          exec ssh -o LogLevel=error ${user}@"$host" progress "$session" "$model" "$mode"
        '';
        zshCompletion = "_arguments '--model[model]:model:(sonnet haiku opus)' '--raw[the condensed activity, no summary]' '1:session:'";
        bashCompletion = ''mapfile -t COMPREPLY < <(compgen -W "--model --raw" -- "$cur")'';
      };
      paste = {
        usage = "[FILE]";
        description = "send an image to the agents' Claude Code, to paste with Ctrl+V";
        help = ''
          Puts an image where the agents' Claude Code takes pasted images from: press
          Ctrl+V in its prompt afterwards, in any session. It's there for
          ${toString (cfg.clipboardMaxAge / 60)} minutes.

          On the host you rarely need this: an image you copy there (a screenshot,
          an image in the browser) is passed on by itself, and copying anything else
          clears it. Elsewhere (the Mac) `agent paste` sends this machine's
          clipboard image to the host over ssh, as ${cfg.hostUser}.

          - `FILE`: an image file to send instead of the clipboard (any format;
            it's sent as PNG). `-` reads it from stdin.

          Only images ever reach the agents, never text, and only the last one.

          Examples:

              agent paste
              agent paste ~/Desktop/screenshot.jpg
        '';
        script =
          let
            # This machine's clipboard image into $tmp
            fromClipboard =
              if pkgs.stdenv.hostPlatform.isDarwin then
                ''
                  # As Claude Code does it on macOS
                  osascript -e "set f to open for access POSIX file \"$tmp\" with write permission" \
                    -e 'write (the clipboard as «class PNGf») to f' -e 'close access f' >/dev/null 2>&1 || true
                ''
              else
                ''
                  type=$(${pkgs.wl-clipboard}/bin/wl-paste --list-types 2>/dev/null | grep -m1 '^image/' || true)
                  [ -z "$type" ] || ${pkgs.wl-clipboard}/bin/wl-paste --no-newline --type "$type" >"$tmp"
                '';
          in
          ''
            tmp=$(mktemp "''${TMPDIR:-/tmp}/agent-paste.XXXXXX")
            trap 'rm -f "$tmp"' EXIT
            if [ $# -eq 0 ]; then
              ${fromClipboard}
            elif [ "$1" = - ]; then
              cat >"$tmp"
            else
              cp -- "$1" "$tmp" || exit 2
            fi
            [ -s "$tmp" ] || { echo "agent paste: no image in the clipboard" >&2; exit 1; }
            # On the host it goes straight in; elsewhere over ssh, as me there
            if [ "$host" = localhost ] && [ -n "${toString cfg.clipboardPut}" ]; then
              ${toString cfg.clipboardPut} "$tmp" && echo "Sent; press Ctrl+V in the agent's prompt"
            else
              ssh -o LogLevel=error "${cfg.hostUser}@$host" .nix-profile/bin/agent-clipboard-put - <"$tmp" &&
                echo "Sent to $host; press Ctrl+V in the agent's prompt"
            fi
          '';
        zshCompletion = "_files";
        bashCompletion = ''mapfile -t COMPREPLY < <(compgen -f -- "$cur")'';
      };
      remote = {
        usage = "<session> [name] | diff <session> <name>";
        description = "how to sync a project from another device to a session, and get its changes back";
        help = ''
          For working on a project from another device in a session on the host.

          `agent remote <session> [name]`, run from the project's directory, prints
          the steps for it; it copies nothing itself. They are: the rsync that copies
          the project into the session's /work/incoming/<name> (gitignored files
          stay behind), what to tell the agent so it imports it as workspace <name>
          (lowercased), how to sync again after you change things, and how to get
          the agent's changes back.

          `agent remote diff <session> <name>` prints the changes in that session's
          workspace <name> as a patch, for `git apply -p2` (or `patch -p2`) in the
          project. On the host it reads the workspace directly; elsewhere it asks
          the host over ssh, as ${cfg.hostUser}.

          - `session`: the session to work in.
          - `name`: the project's name there; the current directory's by default.

          Examples:

              agent remote POS-1234
              agent remote diff POS-1234 android-userland | git apply -p2
        '';
        script = ''
            target=$host
            [ "$target" != localhost ] || target=$(${pkgs.hostname}/bin/hostname)
            dest="${cfg.hostUser}@$target"
            if [ "''${1:-}" = diff ]; then
              [ -n "''${2:-}" ] && [ -n "''${3:-}" ] || { echo "usage: agent remote diff <session> <name>   (agent help remote)" >&2; exit 2; }
              session=''${2} name=''${3}
              name=''${name,,}
              if [ "$host" = localhost ] && [ -n "${toString cfg.workspaceDiff}" ]; then
                exec ${toString cfg.workspaceDiff} "$session" "$name"
              fi
              exec ssh -o LogLevel=error "$dest" .nix-profile/bin/agent remote diff "$session" "$name"
            fi
            [ -n "''${1:-}" ] || { echo "usage: agent remote <session> [name], run from the project directory   (agent help remote)" >&2; exit 2; }
            session=''${1}
            name=''${2:-$(basename "$PWD")}
            for v in "$session" "$name"; do
              [[ $v =~ ^[A-Za-z0-9][A-Za-z0-9._-]{0,62}$ ]] || { echo "agent remote: '$v' needs to be letters, digits, . _ -" >&2; exit 2; }
            done
            incoming=${cfg.sessionsDir}/$session/work/incoming/$name
            # Workspace names are lowercase
            ws=''${name,,}
            cat <<EOF
          Work on $name from another device in the $session session on $target:

          1. On the other device, from $name's directory (gitignored files such as
             build output stay behind; it asks for a password unless you've run
             ssh-copy-id $dest once):

               ssh $dest mkdir -p $incoming && rsync -az --delete --progress --filter=':- .gitignore' ./ $dest:$incoming/

          2. Tell the agent in $session (agent session $session, or
             https://$target:${toString cfg.webPort}/$session):

               $name is in /work/incoming/$name: import it as workspace $ws

             It runs \`workspace import $ws /work/incoming/$name\` and works on that copy.

          3. After changing things on the device: rerun the rsync in step 1 and tell
             the agent to \`workspace update $ws\`. It takes in the new copy and keeps
             its own changes.

          4. Bring its changes back, from $name's directory on the device:

               agent remote diff $session $name | git apply -p2

             Without this config, use ssh $dest .nix-profile/bin/agent remote diff $session $name
             instead of agent remote diff. git apply -p2 works without git too, or use patch -p2.
          EOF
        '';
        # Sessions and their workspaces, where they're local (the host)
        zshCompletion = ''
          local dir=~/${cfg.sessionsDir}
          local -a sessions=($dir/*(/N:t))
          if (( CURRENT == 2 )); then
            compadd -- diff $sessions
          elif [[ $words[2] == diff ]]; then
            if (( CURRENT == 3 )); then
              compadd -- $sessions
            else
              compadd -- $dir/$words[3]/workspaces/*(/N:t)
            fi
          else
            # The name defaults to the directory I'm in
            compadd -- ''${PWD:t}
          fi
        '';
        bashCompletion = ''
          dir=~/${cfg.sessionsDir}
          if (( COMP_CWORD == 2 )); then
            mapfile -t COMPREPLY < <(compgen -W "diff $(ls "$dir" 2>/dev/null)" -- "$cur")
          elif [[ ''${COMP_WORDS[2]} == diff ]]; then
            if (( COMP_CWORD == 3 )); then
              mapfile -t COMPREPLY < <(compgen -W "$(ls "$dir" 2>/dev/null)" -- "$cur")
            else
              mapfile -t COMPREPLY < <(compgen -W "$(ls "$dir/''${COMP_WORDS[3]}/workspaces" 2>/dev/null)" -- "$cur")
            fi
          else
            mapfile -t COMPREPLY < <(compgen -W "$(basename "$PWD")" -- "$cur")
          fi
        '';
      };

      prompt = {
        usage = "[--local] [--model m] <question>";
        description = "ask a one-off question and print the answer";
        help = ''
          Asks a fresh Claude session in the orchestrator container a question,
          prints the answer and exits; nothing carries over between prompts.
          Anything piped in goes along with the question. It has the orchestrator's
          tools and access and doesn't ask for permissions; its Bedrock use counts
          as the session "prompt" in `agent spend`.

          - `--model opus|sonnet|haiku`: the model; Claude Code's default otherwise.
          - `--local`: use the local models (llama.cpp on the host) instead of
            Bedrock.
          - `--host HOST`: the machine running the sandbox.
          - `--`: the end of the options, for a question that starts with `-`.

          Examples:

              agent prompt which falcon defconfig enables CONFIG_ION
              git diff | agent prompt --model sonnet summarise this change
              agent prompt --local explain this error < build.log
        '';
        # A fresh Claude session in the sandbox. Piped stdin goes along, e.g.
        # `git diff | agent prompt review this`. The question travels base64
        # encoded and is validated by agent-attach on the other end
        script = ''
          claude=claude model=default
          while [ $# -gt 0 ]; do
            case "$1" in
              --local) claude="claude-local" ;;
              --model) model=''${2:?--model needs opus, sonnet or haiku}; shift ;;
              --host) host=''${2:?--host needs a host}; shift ;;
              --) shift; break ;;
              *) break ;;
            esac
            shift
          done
          [ $# -gt 0 ] || { echo "usage: agent prompt [--local] [--model opus|sonnet|haiku] [--host host] <question>" >&2; exit 1; }
          payload=$(printf '%s' "$*" | ${pkgs.coreutils}/bin/base64 -w0)
          stdin=()
          [ -t 0 ] && stdin=(-n)
          exec ssh "''${stdin[@]}" -o LogLevel=error ${user}@"$host" prompt "$claude" "$model" "$payload"
        '';
        zshCompletion = ''
          _arguments \
            '--local[use the local models instead of Bedrock]' \
            '--model[model alias]:model:(opus sonnet haiku)' \
            '--host[host running the agent]:host:_hosts' \
            '*:question: '
        '';
        bashCompletion = ''
          case $prev in
            --model) mapfile -t COMPREPLY < <(compgen -W "opus sonnet haiku" -- "$cur") ;;
            --host) mapfile -t COMPREPLY < <(compgen -A hostname -- "$cur") ;;
            *) mapfile -t COMPREPLY < <(compgen -W "--local --model --host" -- "$cur") ;;
          esac
        '';
      };
    };
  };
}
