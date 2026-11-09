% NOTIFS(1) | My tools

# NAME

notifs - browse my desktop notifications from the command line

# SYNOPSIS

**notifs**

**notifs list** [**-n** *count*] [**--app** *text*] [**--since** *30m*|*2h*|*1d*]

**notifs show** *n*

**notifs json** | **clear**

**notifs** **-h** | **--help**

# DESCRIPTION

swaync shows notifications (and has the panel, Super+Shift+N) but can't list
them, so the **notification-log** service records each one as it's sent: it
watches the session bus and changes nothing. **notifs** browses that record,
newest first; it keeps the last 5000.

# COMMANDS

(none)
:   Browse them in fzf, with the highlighted one in full below. **Enter**
    opens the first file or link in it (an agent report's PDF, for example),
    **Ctrl-Y** copies its text, **Esc** leaves.

**list**
:   One line each: number (1 is the newest), time, app and summary; 20 by
    default (**-n**). **--app** keeps those whose app, summary or body
    contains *text*; **--since** those from the last 30m, 2h, 1d, ...

**show** *n*
:   Notification *n* (from **list**) in full: time, app, urgency, summary
    and body, without markup.

**json**
:   The record itself, one JSON object per line: time, app, summary, body,
    urgency, icon.

**clear**
:   Forget them all.

# EXAMPLES

    notifs
    notifs list --since 2h
    notifs list --app agent -n 50
    notifs show 3

# FILES

*~/.local/state/notifications/log.jsonl*
:   The record. It only has notifications sent since notification-log
    started; swaync's own history can't be read.

# SEE ALSO

**swaync-client**(1), **fzf**(1)
