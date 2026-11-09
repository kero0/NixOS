 #!/usr/bin/env python3
 # THIS IS AI SLOP
"""Records every desktop notification sent on my session bus, for `notifs`
(nixos-specific/notification-log). It only watches: swaync still
shows them; this keeps a copy, one JSON object per line, in LOG:
{"time", "app", "summary", "body", "urgency", "icon"}. The newest KEEP stay.

usage: notification-log.py LOG
"""

import datetime as dt
import json
import os
import subprocess
import sys

LOG = sys.argv[1]
KEEP = 5000
URGENCY = {0: "low", 1: "normal", 2: "critical"}


def trim():
    try:
        with open(LOG) as f:
            lines = f.readlines()
    except OSError:
        return
    if len(lines) > KEEP:
        tmp = LOG + ".tmp"
        with open(tmp, "w") as f:
            f.writelines(lines[-KEEP:])
        os.replace(tmp, LOG)


def entry(msg):
    """The notification in a busctl --json=short message, or None."""
    if msg.get("type") != "method_call" or msg.get("member") != "Notify":
        return None
    if msg.get("interface") != "org.freedesktop.Notifications":
        return None
    data = (msg.get("payload") or {}).get("data") or []
    if len(data) < 7:
        return None
    app, _replaces, icon, summary, body, _actions, hints = data[:7]
    urgency = (hints or {}).get("urgency", {}).get("data") if isinstance(hints, dict) else None
    return {
        "time": dt.datetime.now().astimezone().isoformat(timespec="seconds"),
        "app": app,
        "summary": summary,
        "body": body,
        "urgency": URGENCY.get(urgency, "normal"),
        "icon": icon,
    }


def main():
    os.makedirs(os.path.dirname(LOG), exist_ok=True)
    trim()
    mon = subprocess.Popen(
        ["busctl", "--user", "monitor", "org.freedesktop.Notifications", "--json=short"],
        stdout=subprocess.PIPE, text=True,
    )
    written = 0
    for line in mon.stdout:
        try:
            e = entry(json.loads(line))
        except (json.JSONDecodeError, AttributeError, TypeError, ValueError):
            continue
        if not e:
            continue
        with open(LOG, "a") as f:
            f.write(json.dumps(e) + "\n")
        written += 1
        if written % 500 == 0:
            trim()
    sys.exit(mon.wait())


if __name__ == "__main__":
    main()
#!/usr/bin/env python3
